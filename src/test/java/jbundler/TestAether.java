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
        final DefaultArtifact artifact = new DefaultArtifact(coordinates);
        // Add a dummy file to pretend the artifact was resolved
        final Artifact artifactWithFile = artifact.setFile(Mockito.mock(File.class));

        final Dependency dependency = new Dependency(artifactWithFile, null);
        return new DefaultDependencyNode(dependency);
    }
}
