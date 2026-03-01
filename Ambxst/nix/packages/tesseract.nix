{ pkgs }:

[
  (pkgs.tesseract.override {
    enableLanguages = [
      "eng"
      "rus"
    ];
  })
]
