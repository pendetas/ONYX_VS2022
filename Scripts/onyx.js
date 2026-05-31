(function () {
    window.ONYX = window.ONYX || {};

    window.ONYX.formatCurrency = function (value) {
        var number = Number(value || 0);
        return "RM " + number.toFixed(2);
    };
})();
