// Copyright © 2010 - May 2014 Rise Vision Incorporated.
// Use of this software is governed by the GPLv3 license
// (reproduced in the LICENSE file).

package com.risevision.risecache.downloader;

public class DownloadWorker implements Runnable {
	
	private String fileUrl;
	
	public DownloadWorker(String fileUrl) {
		this.fileUrl = fileUrl;
	}

	public synchronized void run() {
		DownloadManager.downloadFileIfModified(fileUrl);
	}

	public static void downloadFileIfModified(String fileUrl) {
		DownloadWorker dw = new DownloadWorker(fileUrl);
		(new Thread(dw, "download worker for URL=" + fileUrl)).start();
		
	}


}
