SecureDesktopSnapchat
=====================

A secure Snapchat-like application for desktop computers.

Created as part of the **CS469: Security Engineering, Fall 2013**, course at George Mason University.

Authors
-------
* Mike Brooks
* Cameron Pelkey
* John Reynolds

Implementation
--------------
### Image Processing
* **OpenCV** is used for capturing image data from a webcam and displaying this image to both host and recipient.
* At no point is the actual image file written onto the disk.

### Security
* Image data is encrypted using **NaCl**, **OpenSSL**, or a similar open source cryptographic library.
* Image data is encrypted immediately upon confirmation by the host and securely sent to one or more recipients.
* Upon acceptance by the recipient, the file is decrypted and displayed for a pre-set length of time.
* Any attempt to take a snapshot of this file through traditional means (i.e. _Print Screen_) is prevented while the image is being displayed to ensure the overal integrity of the system.
* When the length of the display time has elapsed, the image data is destroyed.
