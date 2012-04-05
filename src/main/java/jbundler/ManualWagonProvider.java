package jbundler;

import org.apache.maven.wagon.Wagon;
import org.apache.maven.wagon.providers.http.LightweightHttpWagon;
import org.sonatype.aether.connector.wagon.WagonProvider;

public class ManualWagonProvider implements WagonProvider {

    public Wagon lookup( String roleHint )
        throws Exception {
        if ( "http".equals( roleHint ) ) {
            return new LightweightHttpWagon();
        }
        return null;
    }

    public void release( Wagon wagon ) {

    }

}
