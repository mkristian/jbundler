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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.aether.artifact.Artifact;
import org.eclipse.aether.artifact.DefaultArtifact;
import org.eclipse.aether.graph.DefaultDependencyNode;
import org.eclipse.aether.graph.Dependency;
import org.eclipse.aether.graph.DependencyNode;
import org.mockito.Mockito;
import org.testng.Assert;
import org.testng.annotations.Test;

public class TestAether {

    @Test
    public void testGetResolvedCoordinates() throws Exception {
        final String[] coords = new String[]{
                "a:b:jar:[0,)",
                "b:c:pom:(2.3.4,)",
                "c:d:jar:2.3.4",
                "d:e:jar:[1.8.2,1.8.99999]",
                "e:f:pom:[1.8,1.9.9)",
                "f:g:pom:(1.2,2.0]",
                "a:b:jar:jdk15:[0,)",
                "b:c:pom:jdk15:(2.3.4,)",
                "c:d:jar:jdk15:2.3.4",
                "d:e:jar:jdk15:[1.8.2,1.8.99999]",
                "e:f:pom:jdk15:[1.8,1.9.9)",
                "f:g:pom:jdk15:(1.2,2.0]"};

        final List<DependencyNode> nodes = new ArrayList<DependencyNode>();
        for (final String coord : coords) {
            nodes.add(generateNode(coord));
        }

        final List<String> generatedCoords = Aether.generateCoordinatesForNodes(nodes);
        Assert.assertEquals(generatedCoords, Arrays.asList(coords));
    }

    private DefaultDependencyNode generateNode(final String coordinates) {
        return new DefaultDependencyNode( generateDependency( coordinates ) );
    }
    
    private Dependency generateDependency(final String coordinates) {
        return new Dependency( generateArtifact( coordinates ), null );
    }

    private Artifact generateArtifact(final String coordinates) {
        final DefaultArtifact artifact = new DefaultArtifact(coordinates);
        // Add a dummy file to pretend the artifact was resolved
        return artifact.setFile(Mockito.mock(File.class));
    }
    
    @Test
    public void testResolve() throws Exception {
        Aether aether = new Aether( false );
        
        aether.addArtifact( "org.slf4j:slf4j-simple:jar:(1.6.2,1.7.0)" );
        aether.addArtifact( "ruby.bundler:gem_with_jar:pom:0.0.0" );
        aether.addArtifact( "ruby.bundler:nokogiri-maven:pom:1.5.0" );
        aether.setLocalRepository( new File("./src/example/repo" ) );
        aether.setOffline( true );
        aether.resolve();
        
        final String[] coords = new String[]{
                                             "org.slf4j:slf4j-simple:jar:1.6.6",
                                             "org.slf4j:slf4j-api:jar:1.6.6",
                                             "ruby.bundler:gem_with_jar:pom:0.0.0",
                                             "ruby.bundler:nokogiri-maven:pom:1.5.0",
                                             "msv:isorelax:jar:20050913",
                                             "thaiopensource:jing:jar:20030619",
                                             "nekohtml:nekodtd:jar:0.1.11",
                                             "xml-apis:xml-apis:jar:1.0.b2",
                                             "net.sourceforge.nekohtml:nekohtml:jar:1.9.15",
                                             "xerces:xercesImpl:jar:2.9.0" };
        
        Assert.assertEquals( aether.getResolvedCoordinates(), Arrays.asList( coords ) );
    }
}
