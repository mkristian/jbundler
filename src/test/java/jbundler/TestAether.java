package jbundler;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.mockito.Mockito;
import org.sonatype.aether.artifact.Artifact;
import org.sonatype.aether.graph.Dependency;
import org.sonatype.aether.graph.DependencyNode;
import org.sonatype.aether.util.artifact.DefaultArtifact;
import org.sonatype.aether.util.graph.DefaultDependencyNode;
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
