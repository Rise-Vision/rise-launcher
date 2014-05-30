// Copyright © 2010 - May 2014 Rise Vision Incorporated.
// Use of this software is governed by the GPLv3 license
// (reproduced in the LICENSE file).

package com.risevision.risecache.server;

import java.util.Date;

public class ConnectionInfo {
	
	public int  localPort;
	public Date lastModified;
	public String fileUrl;

	public ConnectionInfo(int localPort, String fileUrl) {
		super();
		this.localPort = localPort;
		this.fileUrl = fileUrl;
		lastModified = new Date();		
	}

}
