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
        if (repository.getProxy() != null )
            url += " via proxy " + repository.getProxy();
        return url;
    }

    public void artifactDownloaded(RepositoryEvent event) {
        out.println("downloaded " + toUrl(event));
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
