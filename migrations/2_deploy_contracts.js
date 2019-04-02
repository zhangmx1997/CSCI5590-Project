var Library = artifacts.require("Library");
var GangToken = artifacts.require("GangToken");
module.exports = function(deployer) {
deployer.deploy(GangToken).then(function() {
    return deployer.deploy(Library, GangToken.address);
});
};
