
v2.1.3+2

Version 2.1.3+2 is required due to compatibility issues with third-party packages, specifically designed for Flutter version 3.13.9. Ensure that you use Flutter 3.13.9 to address this requirement.

It's important to note that even within Flutter 3.13.9, conflicts may arise with the AuthProvider, as it is also defined in the Firebase package. Consequently, we have renamed AuthProvider to resolve this conflict.

Additionally, for compatibility with Xcode 15 and Flutter 3.13.9, certain modifications have been made to the Podfile to facilitate successful app building.

If you currently have version 2.1.3+1, please refer to the changelog file for version 2.1.3+2 for details on the updates.

For first-time installations, it is recommended to review both changelog files sequentially for comprehensive guidance.