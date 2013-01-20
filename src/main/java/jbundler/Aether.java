package jbundler;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.maven.repository.internal.MavenRepositorySystemSession;
import org.apache.maven.repository.internal.MavenServiceLocator;
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
import org.sonatype.aether.repository.LocalRepository;
import org.sonatype.aether.repository.LocalRepositoryManager;
import org.sonatype.aether.repository.RemoteRepository;
import org.sonatype.aether.resolution.DependencyRequest;
import org.sonatype.aether.resolution.DependencyResolutionException;
import org.sonatype.aether.spi.connector.RepositoryConnectorFactory;
import org.sonatype.aether.spi.locator.ServiceLocator;
import org.sonatype.aether.util.artifact.DefaultArtifact;
import org.sonatype.aether.util.graph.PreorderNodeListGenerator;

public class Aether {
    
    private DependencyNode node;
    private RepositorySystem repoSystem;
    private RepositorySystemSession session;
    private List<Artifact> artifacts = new LinkedList<Artifact>();
    private List<RemoteRepository> repos = new LinkedList<RemoteRepository>();
    private Installer installer;

    public Aether(String localRepo, boolean verbose, boolean offline){
        ServiceLocator locator = newServiceLocator();
        repoSystem = locator.getService( RepositorySystem.class );
        installer = locator.getService( Installer.class );
        
        session = newSession( repoSystem, localRepo, verbose, offline );

        RemoteRepository central = new RemoteRepository( "central", "default", "http://repo1.maven.org/maven2/" );
        repos.add(central);
    }
    
    private ServiceLocator newServiceLocator() {
        MavenServiceLocator locator = new MavenServiceLocator();// when using maven 3.0.4   
        //locator.addService( RepositoryConnectorFactory.class, FileRepositoryConnectorFactory.class );
        locator.addService( RepositoryConnectorFactory.class, WagonRepositoryConnectorFactory.class );
        
        locator.setServices( WagonProvider.class, new ManualWagonProvider() );

        return locator;
    }
    
    private RepositorySystemSession newSession( RepositorySystem system, String localRepoPath, boolean verbose, 
            boolean offline ) {
        MavenRepositorySystemSession session = new MavenRepositorySystemSession();

        LocalRepository localRepo = new LocalRepository( localRepoPath );
        session.setLocalRepositoryManager( system.newLocalRepositoryManager( localRepo ) );
        session.setRepositoryListener( new SimpleRepositoryListener(verbose, session.getLocalRepositoryManager()) );
        session.setOffline(offline);
        return session;
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
            collectRequest.addRepository( r );            
        }
        
        node = repoSystem.collectDependencies( session, collectRequest ).getRoot();

        DependencyRequest dependencyRequest = new DependencyRequest( node, null );
        
        repoSystem.resolveDependencies( session, dependencyRequest  );
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
        LocalRepositoryManager lrm = session.getLocalRepositoryManager();

        Artifact artifact = new DefaultArtifact(coordinate);
        
        File dstFile = new File( lrm.getRepository().getBasedir(), lrm.getPathForLocalArtifact( artifact ) );
        if (!dstFile.exists() ){
            artifact = artifact.setFile(new File(file));
            InstallRequest request = new InstallRequest();
            request.addArtifact(artifact);
            installer.install(session, request);
        }
   }
}
