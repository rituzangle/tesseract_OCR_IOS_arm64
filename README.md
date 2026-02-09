# tesseract_OCR_IOS_arm64

Excellent. Below is a production-grade README.md, written to be professional, modular, and quietly confident—with just a touch of personality consistent with your style. It assumes you’ll keep build scripts, Output/, and Scripts/build/.

You can paste this directly as README.md in your repo root.

⸻

:::writing{variant=“standard” id=“55001”}

Tesseract OCR 5.5.2 — iOS XCFramework (arm64)

A clean, reproducible, engineering-grade build of Tesseract OCR 5.5.2 for native iOS integration, packaged as a ready-to-use XCFramework.

Built from source. No black boxes. No mystery binaries. No shortcuts that come back to haunt you later.

This repository exists so your app can focus on recognizing text — not wrestling with build systems.

⸻

What this repository provides
	•	✅ Tesseract OCR 5.5.2
	•	✅ Built for iOS arm64 (real devices)
	•	✅ Packaged as a native XCFramework
	•	✅ Includes all required dependencies:
	•	Leptonica
	•	libjpeg-turbo
	•	libpng
	•	libtiff
	•	zlib
	•	✅ Fully reproducible build system
	•	✅ Clean separation of source, build artifacts, and outputs

No runtime downloads. No dynamic dependencies. No surprises.

⸻

Repository structure

Root/
    ios_arm64/              # Installed static libraries (build output)
    macos_arm64/            # macOS build output (optional)

Output/
    Tesseract.xcframework   # Final framework for Xcode integration

Scripts/build/
    build_all.sh
    build_tesseract.sh
    build_leptonica.sh
    build_libjpeg.sh
    build_libpng.sh
    build_libtiff.sh
    build_zlib.sh
    make_xcframework.sh
    env.sh

Sources/
    tesseract-5.5.2/
    leptonica-1.84.1/
    libjpeg-turbo-3.0.1/
    libpng-1.6.x/
    libtiff-4.x/
    zlib-1.3.1/

Logs/
    build logs for verification and debugging

Build_Artifacts/
    build_manifest.json


⸻

The output you actually care about

Output/Tesseract.xcframework

This is the only artifact your iOS app needs.

Everything else exists to ensure that file is correct, reproducible, and trustworthy.

⸻

Quick integration into Xcode
	1.	Open your Xcode project
	2.	Drag:

Output/Tesseract.xcframework

into:

Project Navigator → Frameworks

	3.	In Target → General → Frameworks, Libraries, and Embedded Content:

Set:

Tesseract.xcframework → Do Not Embed

	4.	Add header search path:

$(PROJECT_DIR)/Frameworks/Tesseract.xcframework/ios-arm64/Headers

	5.	Import in Swift:

import Foundation

and bridge via wrapper (see docs below).

⸻

Verified capabilities

This build supports:
	•	Image OCR
	•	Multi-page OCR
	•	High-resolution scans
	•	PDF page OCR (via rasterization)
	•	Offline operation
	•	On-device processing
	•	Zero network dependency

Ideal for:
	•	document scanning
	•	archival apps
	•	book digitization
	•	heritage preservation
	•	and quiet acts of technological rebellion

⸻

Documentation

Modular documentation is provided:
	•	📘 Integration Guide￼
	•	📘 Swift Wrapper Guide￼
	•	📘 PDF OCR Guide￼
	•	📘 Build System Architecture￼
	•	📘 Reproducibility Notes￼

Each document is focused, independent, and practical.

⸻

Build from source (optional)

To rebuild everything:

Scripts/build/build_all.sh

Output will appear in:

Output/Tesseract.xcframework

Build is deterministic.

If it builds once, it builds forever.

⸻

Version pinning

This repository is pinned to:

Tesseract: 5.5.2
Leptonica: 1.84.1

This protects your app from upstream breakage.

Upgrades are deliberate, never accidental.

⸻

Platform support

Platform	Supported
iOS arm64	✅
iOS Simulator	optional
macOS arm64	optional
macCatalyst	possible
Intel macOS	not included


⸻

Why this exists

Because integrating Tesseract into iOS should not require losing months of your life.

Because reproducibility matters.

Because software should serve the builder — not the other way around.

⸻

License

Tesseract OCR is licensed under Apache License 2.0.

See:

Sources/tesseract-5.5.2/LICENSE

Dependencies retain their respective licenses.

⸻

Maintained for

"Punjabi Virsa" and other applications that care about preserving words, exactly as they were written.
As the name implies, Punjabi Virsa is a project close to my heart.
Punjabi Virsa is, as its name suggests, a deeply personal project.

Its purpose is simple, but meaningful: to scan books and documents in their original Gurmukhi (Punjabi / Panjabi), faithfully capture their text through OCR, and digitize them so they can endure. From there, they can be translated and shared with those who cannot read this rich and beautiful language, but who deserve access to its stories, wisdom, and voice.

Languages do not disappear all at once. They fade slowly — first from daily use, then from shelves, and finally from memory.

This is my small effort to help ensure that does not happen to my Mother Tongue.

A quiet contribution toward preserving heritage, identity, and legacy — exactly as it was written.

⸻

Status

- Production-ready.

- Stable.

- Boring in all the right ways.

⸻

## Author’s note

This repository was built with the philosophy that infrastructure should disappear once it has done its job.

What remains is simple:

Your app.
Your users.
And their words.

⸻

