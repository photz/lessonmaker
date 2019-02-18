"use strict";

exports._getUserMedia = function (just) {
  return function (opts) {
    return function (onError, onSuccess) {
      navigator.mediaDevices.getUserMedia({ audio: true })
        .then(function (mediaSource) {
          onSuccess(just(mediaSource));
        })
        .catch(onError);

      return function (cancelError, cancelerError, cancelerSuccess) {
        cancelerSuccess();
      };
    };
  };
};
  
exports.mediaRecorder = function (mediaStream) {
  return new MediaRecorder(mediaStream);
};

exports.start = function (mediaRecorder) {
  return function () {
    mediaRecorder.start();
  };
};

exports.stop = function (mediaRecorder) {
  return function () {
    mediaRecorder.stop();
  };
};

exports.onDataAvailable = function (mediaRecorder) {
  return function (fn) {
    return function () {
      mediaRecorder.ondataavailable = function (event) {
        console.log('data', event.data);
        fn(event.data)();
      };
    };
  };
};


exports.onStart = function (mediaRecorder) {
  return function (fn) {
    return function () {
      mediaRecorder.onstart = function (event) {
        fn();
      };
    };
  };
};


exports.onStop = function (mediaRecorder) {
  return function (fn) {
    return function () {
      mediaRecorder.onstop = function (event) {
        fn();
      };
    };
  };
};
