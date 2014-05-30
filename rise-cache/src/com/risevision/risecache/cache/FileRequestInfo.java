// Copyright © 2010 - May 2014 Rise Vision Incorporated.
// Use of this software is governed by the GPLv3 license
// (reproduced in the LICENSE file).

package com.risevision.risecache.cache;

import java.util.Date;

public class FileRequestInfo {

	public String url;
	public Date lastRequested;
	public boolean downloadComplete;
	
	public FileRequestInfo(String url) {
		this.url = url;
		setDownloadComplete(false);
	}

	public void setDownloadComplete(boolean value) {
		downloadComplete = value;
		if (!value) {
			this.lastRequested = new Date();
		}
	}

}
