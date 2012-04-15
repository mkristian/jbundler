package jbundler;

import java.io.PrintStream;

import org.sonatype.aether.AbstractRepositoryListener;
import org.sonatype.aether.RepositoryEvent;
import org.sonatype.aether.repository.LocalRepositoryManager;
import org.sonatype.aether.repository.RemoteRepository;

public class SimpleRepositoryListener extends AbstractRepositoryListener {

    private PrintStream out = System.out;
    private PrintStream err = System.err;
    private final boolean verbose;
    private LocalRepositoryManager lrm;

    public SimpleRepositoryListener(LocalRepositoryManager lrm) {
        this(false, lrm);
    }

    public SimpleRepositoryListener(boolean verbose, LocalRepositoryManager lrm) {
        this.verbose = verbose;
        this.lrm = lrm;
    }

    public void artifactDescriptorInvalid(RepositoryEvent event) {
        err.println("artifact descriptor invalid: " + event.getArtifact()
                + " : " + event.getException().getMessage());
    }

    public void artifactDescriptorMissing(RepositoryEvent event) {
        err.println("artifact descriptor missing: " + event.getArtifact());
    }

    public void artifactInstalled(RepositoryEvent event) {
        if (verbose) {
            out.println("artifact installed: " + event.getArtifact() + " : "
                + event.getFile());
        }   
    }

    public void artifactResolved(RepositoryEvent event) {
        if (verbose) {
            out.println("artifact resolved: " + event.getArtifact() + " : "
                + event.getRepository().getId());
        }
    }

    public void artifactDownloading(RepositoryEvent event) {
        out.println("downloading " + toUrl(event));
    }

    private String toUrl(RepositoryEvent event) {
        RemoteRepository repository = (RemoteRepository) event.getRepository();
        String path = lrm.getPathForRemoteArtifact(event.getArtifact(), repository, null);
        String url = repository.getUrl() + "/" + path;
        return url;
    }

    public void artifactDownloaded(RepositoryEvent event) {
        out.println("artifact downloaded: " + event.getArtifact());
    }

    public void metadataInvalid(RepositoryEvent event) {
        err.println("metadata invalid: " + event.getMetadata());
    }

    public void metadataResolved(RepositoryEvent event) {
        if (verbose) {
            out.println("metadata resolved: " + event.getMetadata() + " : "
                + event.getRepository().getId());
        }
    }
}
