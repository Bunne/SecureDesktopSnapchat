SecureDesktopSnapchat
=====================

A secure Snapchat-like application for OS X.

Created as part of the **CS469: Security Engineering, Fall 2013**, course at George Mason University.

Authors
-------
* Cameron Pelkey
* Mike Brooks
* John Reynolds

Implementation
--------------
### Image Processing
* The in-built **iSight** camera is used for capturing image data.
* At no point is the actual image file written onto the disk.

### Security
* Image data is encrypted using **OpenSSL**.
* **Public/Private key encryption** is used to secure image data.
* Image data is encrypted immediately and securely sent to one or more recipients.
* Upon acceptance by the recipient, the file is decrypted and displayed for a pre-set length of time.
* Any and all images generated on the system while the program is operating are destroyed for the sake of security.
* When the length of the display time has elapsed, the image data is destroyed.

### IMPORTANT
Due to limitations in time and execution of the project, during the 10-second window during which the image is displayed any changes detected on the disk wherein an image file is concerned will be deleted. In this time frame, it is suggested that you do not save, move, or otherwise interact with images or directories that contain images.
