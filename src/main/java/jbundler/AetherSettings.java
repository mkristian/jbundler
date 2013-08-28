/*******************************************************************************
 * Copyright (c) 2010, 2012 Sonatype, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Sonatype, Inc. - initial API and implementation
 *******************************************************************************/

/** 
 * this basically the file wth some inlines and strips here and there
 * 
 * http://git.eclipse.org/c/aether/aether-ant.git/tree/src/main/java/org/eclipse/aether/ant/AntRepoSys.java
 * 
 */
package jbundler;

import java.io.File;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

import org.apache.maven.settings.Mirror;
import org.apache.maven.settings.Server;
import org.apache.maven.settings.Settings;
import org.apache.maven.settings.building.DefaultSettingsBuilderFactory;
import org.apache.maven.settings.building.DefaultSettingsBuildingRequest;
import org.apache.maven.settings.building.SettingsBuilder;
import org.apache.maven.settings.building.SettingsBuildingException;
import org.eclipse.aether.repository.AuthenticationSelector;
import org.eclipse.aether.repository.LocalRepository;
import org.eclipse.aether.repository.MirrorSelector;
import org.eclipse.aether.repository.Proxy;
import org.eclipse.aether.repository.ProxySelector;
import org.eclipse.aether.util.repository.AuthenticationBuilder;
import org.eclipse.aether.util.repository.ConservativeAuthenticationSelector;
import org.eclipse.aether.util.repository.DefaultAuthenticationSelector;
import org.eclipse.aether.util.repository.DefaultMirrorSelector;
import org.eclipse.aether.util.repository.DefaultProxySelector;

public class AetherSettings {

    private static final SettingsBuilder settingsBuilder = new DefaultSettingsBuilderFactory().newInstance();
    //private static SettingsDecrypter settingsDecrypter;// = new DefaultSettingsDecryptorFactory().newInstance();
    
    private File globalSettings;
    private File userSettings;
    private List<Proxy> proxies = new LinkedList<Proxy>();;
    private Settings settings;
    private List<Mirror> mirrors = new LinkedList<Mirror>();
//    private List<Authentication> authentications;
    private Boolean offline;
    private LocalRepository localRepository;
    
    LocalRepository getLocalRepository()
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
    
    void setLocalRepository( LocalRepository localRepository )
    {
        this.localRepository = localRepository;
    }
    
    synchronized Settings getSettings()
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
    
    ProxySelector getProxySelector()
    {
        DefaultProxySelector selector = new DefaultProxySelector();

        for ( Proxy proxy : proxies )
        {
            selector.add( proxy, proxy.getHost() );
        }

        Settings settings = getSettings();
        for ( org.apache.maven.settings.Proxy proxy : settings.getProxies() )
        {
            AuthenticationBuilder auth = new AuthenticationBuilder();
            auth.addUsername( proxy.getUsername() );
            auth.addPassword( proxy.getPassword() );

            selector.add( new Proxy( proxy.getProtocol(), proxy.getHost(),
                                     proxy.getPort(), auth.build() ),
                          proxy.getNonProxyHosts() );
        }
        return selector;
    }  
    
    AuthenticationSelector getAuthSelector()
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
            AuthenticationBuilder auth = new AuthenticationBuilder();
            auth.addUsername( server.getUsername() );
            auth.addPassword( server.getPassword() );
            auth.addPrivateKey( server.getPrivateKey(), server.getPassphrase() );
            selector.add( server.getId(), auth.build() );
        }

        return new ConservativeAuthenticationSelector( selector );
    }

    String getUserAgent()
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

    void setOffline( Boolean offline )
    {
        this.offline = offline;
    }
    
    boolean isOffline()
    {
        return offline == null ? getSettings().isOffline() : offline;
    }
    
    Properties getSystemProperties()
    {
        Properties props = new Properties();
        getEnvProperties( props );
        props.putAll( System.getProperties() );
        return props;
    }

    Properties getUserProperties()
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
    
    void addMirror( Mirror mirror )
    {
        mirrors.add( mirror );
    }
        
    MirrorSelector getMirrorSelector()
    {
        DefaultMirrorSelector selector = new DefaultMirrorSelector();

        for ( Mirror mirror : mirrors )
        {
            selector.add( mirror.getId(), mirror.getUrl(), "default", true, mirror.getMirrorOf(), null );
        }

        Settings settings = getSettings();
        for ( org.apache.maven.settings.Mirror mirror : settings.getMirrors() )
        {
            selector.add( String.valueOf( mirror.getId() ), mirror.getUrl(), mirror.getLayout(), true,
                          mirror.getMirrorOf(), mirror.getMirrorOfLayouts() );
        }

        return selector;
    }

    synchronized void setUserSettings( File file )
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
    
    private String getMavenHome()
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
    
    void addProxy( Proxy proxy )
    {
        proxies.add( proxy );
    }

}
