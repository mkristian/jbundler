package jbundler;

import java.io.PrintStream;

import org.sonatype.aether.AbstractRepositoryListener;
import org.sonatype.aether.RepositoryEvent;

public class ConsoleRepositoryListener extends AbstractRepositoryListener {

    private PrintStream out = System.out;
    private PrintStream err = System.err;
    private final boolean verbose;

    public ConsoleRepositoryListener() {
        this(false);
    }

    public ConsoleRepositoryListener(boolean verbose) {
        this.verbose = verbose;
    }

//    public void artifactDeployed(RepositoryEvent event) {
//        out.println("Deployed " + event.getArtifact() + " to "
//                + event.getRepository());
//    }
//
//    public void artifactDeploying(RepositoryEvent event) {
//        out.println("Deploying " + event.getArtifact() + " to "
//                + event.getRepository());
//    }

    public void artifactDescriptorInvalid(RepositoryEvent event) {
        err.println("Invalid artifact descriptor for " + event.getArtifact()
                + ": " + event.getException().getMessage());
    }

    public void artifactDescriptorMissing(RepositoryEvent event) {
        err.println("Missing artifact descriptor for " + event.getArtifact());
    }

    public void artifactInstalled(RepositoryEvent event) {
        out.println("Installed " + event.getArtifact() + " to "
                + event.getFile());
    }

    public void artifactInstalling(RepositoryEvent event) {
        out.println("Installing " + event.getArtifact() + " to "
                + event.getFile());
    }

    public void artifactResolved(RepositoryEvent event) {
        if (verbose) {
            out.println("Resolved artifact " + event.getArtifact() + " from "
                + event.getRepository().getId());
        }
    }

    public void artifactDownloading(RepositoryEvent event) {
        out.println("Downloading artifact " + event.getArtifact() + " from "
                + event.getRepository().getId());
    }

    public void artifactDownloaded(RepositoryEvent event) {
        out.println("Downloaded artifact " + event.getArtifact() + " from "
                + event.getRepository().getId());
    }

    public void artifactResolving(RepositoryEvent event) {
        if (verbose) {
            out.println("Resolving artifact " + event.getArtifact());
        }
    }
//
//    public void metadataDeployed(RepositoryEvent event) {
//        out.println("Deployed " + event.getMetadata() + " to "
//                + event.getRepository());
//    }
//
//    public void metadataDeploying(RepositoryEvent event) {
//        out.println("Deploying " + event.getMetadata() + " to "
//                + event.getRepository());
//    }

//    public void metadataInstalled(RepositoryEvent event) {
//        out.println("Installed " + event.getMetadata() + " to "
//                + event.getFile());
//    }
//
//    public void metadataInstalling(RepositoryEvent event) {
//        out.println("Installing " + event.getMetadata() + " to "
//                + event.getFile());
//    }

    public void metadataInvalid(RepositoryEvent event) {
        err.println("Invalid metadata " + event.getMetadata());
    }

    public void metadataResolved(RepositoryEvent event) {
        if (verbose) {
            out.println("Resolved metadata " + event.getMetadata() + " from "
                + event.getRepository());
        }
    }

    public void metadataResolving(RepositoryEvent event) {
        if (verbose) {
            out.println("Resolving metadata " + event.getMetadata() + " from "
                + event.getRepository());
        }
    }

}
