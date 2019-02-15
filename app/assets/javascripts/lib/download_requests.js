// Starts a download and waits for it to finish.  The download request is
// created by performing a HTTP request for the specified method and url
// with the associated parameters.  This is expected to return a json blob
// with two urls, the status and download links for the DownloadRequest.
//
// No matter what happens; whether there is a successful download created,
// an error, or a timeout; the given callback function is invoked so you
// can update the UI on progress.
function startDownloadRequest(method, url, params, callback) {
  function waitForDownloadRequest(data) {
    var status_url = data.status;
    var download_url = data.download;
    var start_time = new Date();
    var timeout = 15; // seconds TODO how do we pull this from DownloadRequest::MIN_TIME_TO_AUTO_DESTROY?
  
    (function poll() {
      setTimeout(function() {
        $.ajax({
          type: 'GET',
          url: status_url,
          success: function (response) {
            if (response.status == 'complete') {
              callback();
              $('div[data-content-key=flash-content]').html('');
              window.location.replace(download_url + '?expire_if_auto_downloaded=true');
            } else if (response.status == 'error') {
              $('div[data-content-key=flash-content]').html('<div class="alert alert-danger">There was an error generating this report.</div>');
              callback();
            } else {
              if ((new Date() - start_time) > timeout * 1000) {
                $('div[data-content-key=flash-content]').html('<div class="alert alert-warning">This report is taking a bit... please go <a href="/download_requests">here</a> to check on the status.</div>');
                callback();
              } else {
                poll(); // continue waiting until complete or timeout
              }
            }
          }
        });
      }, 1000);
    })();
  };

  $.ajax({
    type: method,
    url: url,
    data: params,
    success: waitForDownloadRequest
  });
}
