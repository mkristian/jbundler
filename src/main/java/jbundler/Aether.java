package jbundler;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import org.apache.maven.repository.internal.MavenRepositorySystemSession;
import org.apache.maven.repository.internal.MavenServiceLocator;
import org.apache.maven.settings.Mirror;
import org.apache.maven.settings.Server;
import org.apache.maven.settings.Settings;
import org.apache.maven.settings.building.DefaultSettingsBuilderFactory;
import org.apache.maven.settings.building.DefaultSettingsBuildingRequest;
import org.apache.maven.settings.building.SettingsBuilder;
import org.apache.maven.settings.building.SettingsBuildingException;
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
import org.sonatype.aether.repository.AuthenticationSelector;
import org.sonatype.aether.repository.LocalRepository;
import org.sonatype.aether.repository.LocalRepositoryManager;
import org.sonatype.aether.repository.MirrorSelector;
import org.sonatype.aether.repository.Proxy;
import org.sonatype.aether.repository.ProxySelector;
import org.sonatype.aether.repository.RemoteRepository;
import org.sonatype.aether.resolution.DependencyRequest;
import org.sonatype.aether.resolution.DependencyResolutionException;
import org.sonatype.aether.spi.connector.RepositoryConnectorFactory;
import org.sonatype.aether.spi.locator.ServiceLocator;
import org.sonatype.aether.util.artifact.DefaultArtifact;
import org.sonatype.aether.util.graph.PreorderNodeListGenerator;
import org.sonatype.aether.util.repository.ConservativeAuthenticationSelector;
import org.sonatype.aether.util.repository.DefaultAuthenticationSelector;
import org.sonatype.aether.util.repository.DefaultMirrorSelector;
import org.sonatype.aether.util.repository.DefaultProxySelector;

public class Aether {

    private static final SettingsBuilder settingsBuilder = new DefaultSettingsBuilderFactory().newInstance();
    //private static SettingsDecrypter settingsDecrypter;// = new DefaultSettingsDecryptorFactory().newInstance();
    private DependencyNode node;
    private RepositorySystem repoSystem;
    private RepositorySystemSession session;
    private List<Artifact> artifacts = new LinkedList<Artifact>();
    private List<RemoteRepository> repos = new LinkedList<RemoteRepository>();
    private Installer installer;
    
    private File globalSettings;
    private File userSettings;
    private List<Proxy> proxies = new LinkedList<Proxy>();;
    private Settings settings;
    private List<Mirror> mirrors = new LinkedList<Mirror>();
//    private List<Authentication> authentications;
    private Boolean offline;
    private LocalRepository localRepository;

    public Aether(String localRepo, boolean verbose, Boolean offline){
        setLocalRepository( new File(localRepo) );
        ServiceLocator locator = newServiceLocator();
        repoSystem = locator.getService( RepositorySystem.class );
        installer = locator.getService( Installer.class );
        
        this.offline = offline;
        
        session = newSession( repoSystem, verbose );

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
    
    private RepositorySystemSession newSession( RepositorySystem system, boolean verbose ) {
        
        MavenRepositorySystemSession session = new MavenRepositorySystemSession();

        Map<Object, Object> configProps = new LinkedHashMap<Object, Object>();
        configProps.put( ConfigurationProperties.USER_AGENT, getUserAgent() );
        configProps.putAll( System.getProperties() );
        //configProps.putAll( (Map<?, ?>) getProperties() );
        configProps.putAll( (Map<?, ?>) getUserProperties() );
        session.setConfigProps( configProps );
        
        session.setLocalRepositoryManager( system.newLocalRepositoryManager( getLocalRepository() ) );
        session.setRepositoryListener( new SimpleRepositoryListener( verbose, session.getLocalRepositoryManager() ) );
        session.setOffline(isOffline());
        session.setMirrorSelector(getMirrorSelector());
        session.setAuthenticationSelector(getAuthSelector());
        session.setProxySelector(getProxySelector());
        session.setUserProps(getUserProperties());
        session.setSystemProps(getSystemProperties());
        return session;
    }

    private LocalRepository getLocalRepository()
    {
        if ( localRepository != null && localRepository.getBasedir() != null )
        {
            return localRepository;
        }
        else
        {
            return new LocalRepository( getDefaultLocalRepoDir() );
        }
    }
    
    private File getDefaultLocalRepoDir()
    {

        Settings settings = getSettings();
        if ( settings.getLocalRepository() != null )
        {
            return new File( settings.getLocalRepository() );
        }

        return new File( new File( System.getProperty( "user.home" ), ".m2" ), "repository" );
    }
    
    public void setLocalRepository( File localRepository )
    {
        this.localRepository = new LocalRepository( localRepository );
    }
    
    private synchronized Settings getSettings()
    {
        if ( settings == null )
        {
            DefaultSettingsBuildingRequest request = new DefaultSettingsBuildingRequest();
            request.setUserSettingsFile( getUserSettings() );
            request.setGlobalSettingsFile( getGlobalSettings() );
            request.setSystemProperties( getSystemProperties() );
            request.setUserProperties( getUserProperties() );

            try
            {
                settings = settingsBuilder.build( request ).getEffectiveSettings();
            }
            catch ( SettingsBuildingException e )
            {
                //log( "Could not process settings.xml: " + e.getMessage(), e );
            }

//            SettingsDecryptionResult result =
//                settingsDecrypter.decrypt( new DefaultSettingsDecryptionRequest( settings ) );
//            settings.setServers( result.getServers() );
//            settings.setProxies( result.getProxies() );
        }
        return settings;
    }
    
    private ProxySelector getProxySelector()
    {
        DefaultProxySelector selector = new DefaultProxySelector();

        for ( Proxy proxy : proxies )
        {
            selector.add( proxy, proxy.getHost() );
        }

        Settings settings = getSettings();
        for ( org.apache.maven.settings.Proxy proxy : settings.getProxies() )
        {
            Authentication auth = new Authentication( proxy.getUsername(),  proxy.getPassword() );

            selector.add( new Proxy( proxy.getProtocol(), proxy.getHost(),
                                                                   proxy.getPort(), auth ),
                          proxy.getNonProxyHosts() );
        }

        return selector;
    }  
    
    private String getUserAgent()
    {
        StringBuilder buffer = new StringBuilder( 128 );

        buffer.append( "JBundler/" );//.append( getProperty( "jbundler.version" ) );
        buffer.append( " (" );
        buffer.append( "Java " ).append( System.getProperty( "java.version" ) );
        buffer.append( "; " );
        buffer.append( System.getProperty( "os.name" ) ).append( " " ).append( System.getProperty( "os.version" ) );
        buffer.append( ")" );
        buffer.append( " Aether" );

        return buffer.toString();
    }

    private boolean isOffline()
    {
//        String prop = project.getProperty( Names.PROPERTY_OFFLINE );
//        if ( prop != null )
//        {
//            return Boolean.parseBoolean( prop );
//        }
        return offline != null ? getSettings().isOffline() : offline;
    }
    
    private Properties getSystemProperties()
    {
        Properties props = new Properties();
        getEnvProperties( props );
        props.putAll( System.getProperties() );
        return props;
    }

    private Properties getUserProperties()
    {
        Properties props = new Properties();
        return props;
    }

    private Properties getEnvProperties( Properties props )
    {
        if ( props == null )
        {
            props = new Properties();
        }
        boolean envCaseInsensitive = false;//Os.isFamily( "windows" );
        for ( Map.Entry<String, String> entry : System.getenv().entrySet() )
        {
            String key = entry.getKey();
            if ( envCaseInsensitive )
            {
                key = key.toUpperCase( Locale.ENGLISH );
            }
            key = "env." + key;
            props.put( key, entry.getValue() );
        }
        return props;
    }
    
    private MirrorSelector getMirrorSelector()
    {
        DefaultMirrorSelector selector = new DefaultMirrorSelector();

        for ( Mirror mirror : mirrors )
        {
            selector.add( mirror.getId(), mirror.getUrl(), "default", false, mirror.getMirrorOf(), null );
        }

        Settings settings = getSettings();
        for ( org.apache.maven.settings.Mirror mirror : settings.getMirrors() )
        {
            selector.add( String.valueOf( mirror.getId() ), mirror.getUrl(), mirror.getLayout(), false,
                          mirror.getMirrorOf(), mirror.getMirrorOfLayouts() );
        }

        return selector;
    }

    private AuthenticationSelector getAuthSelector()
    {
        DefaultAuthenticationSelector selector = new DefaultAuthenticationSelector();

//        Collection<String> ids = new HashSet<String>();
//        for ( Authentication auth : authentications )
//        {
//            List<String> servers = auth.getServers();
//            if ( !servers.isEmpty() )
//            {
//                org.eclipse.aether.repository.Authentication a = ConverterUtils.toAuthentication( auth );
//                for ( String server : servers )
//                {
//                    if ( ids.add( server ) )
//                    {
//                        selector.add( server, a );
//                    }
//                }
//            }
//        }

        Settings settings = getSettings();
        for ( Server server : settings.getServers() )
        {
            Authentication auth = new Authentication( server.getUsername(), server.getPassword(),
                    server.getPrivateKey(), server.getPassphrase() );
            selector.add( server.getId(), auth );
        }

        return new ConservativeAuthenticationSelector( selector );
    }

    public synchronized void setUserSettings( File file )
    {
//        if ( !eq( this.userSettings, file ) )
//        {
//            settings = null;
//        }
        this.userSettings = file;
    }

    File getUserSettings()
    {
        if ( userSettings == null )
        {
            userSettings = new File( new File( System.getProperty( "user.home" ), ".m2" ), "settings.xml" );
        }
        return userSettings;
    }

//    public void setGlobalSettings( File file )
//    {
//        if ( !eq( this.globalSettings, file ) )
//        {
//            settings = null;
//        }
//        this.globalSettings = file;
//    }
        String getMavenHome()
        {
            String mavenHome = System.getProperty( "maven.home" );
            if ( mavenHome != null )
            {
                return mavenHome;
            }
            return System.getenv( "M2_HOME" );
        }
    File getGlobalSettings()
    {
        if ( globalSettings == null )
        {
            globalSettings = new File( new File( getMavenHome(), "conf" ), "settings.xml" );
        }
        return globalSettings;
    }

    public void addProxy( Proxy proxy )
    {
        proxies.add( proxy );
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
