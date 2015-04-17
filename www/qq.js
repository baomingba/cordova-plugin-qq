var exec = require('cordova/exec');

module.exports = {
    login: function(onSuccess, onFail) {
        exec(onSuccess, onFail, 'QQ', 'login', []);
    },

    logout: function(onSuccess, onFail) {
        exec(onSuccess, onFail, 'QQ', 'logout', []);
    }
}


