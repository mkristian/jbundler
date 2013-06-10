/*
 * Copyright (C) 2013 Kristian Meier
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package jbundler;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.maven.repository.internal.MavenRepositorySystemSession;
import org.apache.maven.repository.internal.MavenServiceLocator;
import org.apache.maven.settings.Mirror;
import org.sonatype.aether.ConfigurationProperties;
import org.sonatype.aether.RepositorySystem;
import org.sonatype.aether.RepositorySystemSession;
import org.sonatype.aether.artifact.Artifact;
import org.sonatype.aether.collection.CollectRequest;
import org.sonatype.aether.collection.DependencyCollectionException;
import org.sonatype.aether.connector.wagon.WagonProvider;
import org.sonatype.aether.connector.wagon.WagonRepositoryConnectorFactory;
import org.sonatype.aether.graph.Dependency;
import org.sonatype.aether.graph.DependencyNode;
import org.sonatype.aether.impl.Installer;
import org.sonatype.aether.installation.InstallRequest;
import org.sonatype.aether.installation.InstallationException;
import org.sonatype.aether.repository.Authentication;
import org.sonatype.aether.repository.LocalRepository;
import org.sonatype.aether.repository.LocalRepositoryManager;
import org.sonatype.aether.repository.Proxy;
import org.sonatype.aether.repository.RemoteRepository;
import org.sonatype.aether.resolution.DependencyRequest;
import org.sonatype.aether.resolution.DependencyResolutionException;
import org.sonatype.aether.spi.connector.RepositoryConnectorFactory;
import org.sonatype.aether.spi.locator.ServiceLocator;
import org.sonatype.aether.util.artifact.DefaultArtifact;
import org.sonatype.aether.util.graph.PreorderNodeListGenerator;

public class Aether {

    private DependencyNode node;
    private final RepositorySystem repoSystem;
    private RepositorySystemSession session;
    private List<Artifact> artifacts = new LinkedList<Artifact>();
    private List<RemoteRepository> repos = new LinkedList<RemoteRepository>();
    private final Installer installer;
    
    private final AetherSettings settings = new AetherSettings();
    
    private final boolean verbose;

    public Aether(boolean verbose){
        this.verbose = verbose;
        ServiceLocator locator = newServiceLocator();
        this.repoSystem = locator.getService( RepositorySystem.class );
        this.installer = locator.getService( Installer.class );
        
        repos.add( new RemoteRepository( "central",
                                          "default",
                                          "http://repo.maven.apache.org/maven2" ) );
    }
    
    private RepositorySystemSession getSession()
    {
        if (this.session == null)
        {
            MavenRepositorySystemSession s = new MavenRepositorySystemSession();
            
            Map<Object, Object> configProps = new LinkedHashMap<Object, Object>();
            configProps.put( ConfigurationProperties.USER_AGENT, settings.getUserAgent() );
            configProps.putAll( System.getProperties() );
            //configProps.putAll( (Map<?, ?>) getProperties() );
            configProps.putAll( (Map<?, ?>) settings.getUserProperties() );
            s.setConfigProps( configProps );
            
            s.setLocalRepositoryManager( repoSystem.newLocalRepositoryManager( settings.getLocalRepository() ) );
            s.setRepositoryListener( new SimpleRepositoryListener( verbose, s.getLocalRepositoryManager() ) );
            s.setOffline(settings.isOffline());
            s.setMirrorSelector(settings.getMirrorSelector());
            s.setAuthenticationSelector(settings.getAuthSelector());
            s.setProxySelector(settings.getProxySelector());
            s.setUserProps(settings.getUserProperties());
            s.setSystemProps(settings.getSystemProperties());
            this.session = s;
        }
        return this.session;
    }
        
    private ServiceLocator newServiceLocator() {
        MavenServiceLocator locator = new MavenServiceLocator();// when using maven 3.0.4
        //locator.addService( RepositoryConnectorFactory.class, FileRepositoryConnectorFactory.class );
        locator.addService( RepositoryConnectorFactory.class, WagonRepositoryConnectorFactory.class );
        
        locator.setServices( WagonProvider.class, new ManualWagonProvider() );

        return locator;
    }
    
    public void setLocalRepository( File localRepository )
    {
        this.settings.setLocalRepository( new LocalRepository( localRepository ) );
    }    
    
    public void addMirror( String url )
    {
        Mirror mirror = new Mirror();
        mirror.setId( "jbundler" );
        mirror.setLayout( "default" );
        mirror.setMirrorOf( "central" );
        mirror.setName( "JBundler Maven Central Mirror" );
        mirror.setUrl( url );
        mirror.setMirrorOfLayouts( "*" );
        settings.addMirror( mirror );
    }


    public void setOffline( Boolean offline )
    {
        this.settings.setOffline( offline );
    }
        public synchronized void setUserSettings( File file )
    {
//        if ( !eq( this.userSettings, file ) )
//        {
//            settings = null;
//        }
        this.settings.setUserSettings( file );
    }

        
    public void addProxy( String url )
    {
        URL u;
        try
        {
            u = new URL( url );
        } 
        catch (MalformedURLException e)
        {
            throw new RuntimeException( "can not parse given url: " + url, e );
        }
        
        final Authentication authentication;
        final String userInfo = u.getUserInfo();
        if ( userInfo != null &&  userInfo.contains( ":" ) )
        {
            int i = userInfo.indexOf(':');
            authentication = new Authentication( userInfo.substring( 0, i ), userInfo.substring( i + 1 ) );
        }
        else
        {
            authentication = new Authentication( null, (String)null );
        }
        settings.addProxy( new Proxy( u.getProtocol(), u.getHost(), u.getPort(), authentication ) );
    }

    public void addArtifact(String coordinate){
        artifacts.add(new DefaultArtifact(coordinate));
    }
    
    public void addRepository(String id, String url){
        repos.add(new RemoteRepository(id, "default", url));
    }

    public void resolve() throws DependencyCollectionException, DependencyResolutionException {
        if (artifacts.size() == 0){
            throw new IllegalArgumentException("no artifacts given");
        }
       
        CollectRequest collectRequest = new CollectRequest();
        for( Artifact a: artifacts ){
            collectRequest.addDependency( new Dependency( a, "compile" ) );
        }

        for( RemoteRepository r: repos ){
            RemoteRepository mirror = settings.getMirrorSelector().getMirror( r );
            if ( mirror != null )
            {
                r = mirror;
            }
            Proxy proxy = settings.getProxySelector().getProxy( r );
            if ( proxy != null )
            {
                r.setProxy( proxy );
            }
            
            collectRequest.addRepository( r );            
        }
                
        node = repoSystem.collectDependencies( getSession(), collectRequest ).getRoot();

        DependencyRequest dependencyRequest = new DependencyRequest( node, null );
        
        repoSystem.resolveDependencies( getSession(), dependencyRequest  );
    }

    public List<RemoteRepository> getRepositories(){
        return Collections.unmodifiableList( repos );
    }

    public List<Artifact> getArtifacts(){
        return Collections.unmodifiableList( artifacts );
    }
    
    public String getClasspath() {
        PreorderNodeListGenerator nlg = new PreorderNodeListGenerator();
        node.accept( nlg );
        
        StringBuilder buffer = new StringBuilder( 1024 );

        for ( Iterator<DependencyNode> it = nlg.getNodes().iterator(); it.hasNext(); )
        {
            DependencyNode node = it.next();
            if ( node.getDependency() != null )
            {
                Artifact artifact = node.getDependency().getArtifact();
                // skip pom artifacts
                if ( artifact.getFile() != null && !"pom".equals(artifact.getExtension()))
                {
                    buffer.append( artifact.getFile().getAbsolutePath() );
                    if ( it.hasNext() )
                    {
                        buffer.append( File.pathSeparatorChar );
                    }
                }
            }
        }

        return buffer.toString();
    }
    
    public List<String> getResolvedCoordinates() {
        PreorderNodeListGenerator nlg = new PreorderNodeListGenerator();
        node.accept( nlg );

        return generateCoordinatesForNodes(nlg.getNodes());
    }

    //@VisibleForTesting
    static List<String> generateCoordinatesForNodes(final List<DependencyNode> nodes) {
        final List<String> result = new ArrayList<String>();
        for (final DependencyNode node : nodes) {
            if (node.getDependency() != null) {
                final Artifact artifact = node.getDependency().getArtifact();
                if (artifact.getFile() != null) {
                    final StringBuilder coord = new StringBuilder(artifact.getGroupId()).append(":")
                                                                                        .append(artifact.getArtifactId())
                                                                                        .append(":")
                                                                                        .append(artifact.getExtension())
                                                                                        .append(":");
                    // The classifier should never be null
                    if (!artifact.getClassifier().isEmpty()) {
                        coord.append(artifact.getClassifier()).append(":");
                    }

                    coord.append(artifact.getVersion());
                    result.add(coord.toString());
                }
            }
        }

        return result;
    }

    public void install(String coordinate, String file) throws InstallationException{
        LocalRepositoryManager lrm = getSession().getLocalRepositoryManager();

        Artifact artifact = new DefaultArtifact(coordinate);
        
        File dstFile = new File( lrm.getRepository().getBasedir(), lrm.getPathForLocalArtifact( artifact ) );
        if (!dstFile.exists() ){
            artifact = artifact.setFile(new File(file));
            InstallRequest request = new InstallRequest();
            request.addArtifact(artifact);
            installer.install(getSession(), request);
        }
   }
}
