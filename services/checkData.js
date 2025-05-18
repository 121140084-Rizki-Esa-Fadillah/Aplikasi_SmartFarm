const User = require("../models/user");
const Kolam = require("../models/kolam");

const checkUserExistence = async (username, email) => {
    const existingUsername = await User.model.findOne({ username });
    const existingEmail = await User.model.findOne({ email });

    return {
        usernameExists: !!existingUsername,
        emailExists: !!existingEmail,
    };
};

const checkKolamExistence = async (idPond, namePond) => {
    const existingIdPond = await Kolam.model.findOne({ idPond });
    const existingNamePond = await Kolam.model.findOne({ namePond });

    return {
        idPondExists: !!existingIdPond,
        namePondExists: !!existingNamePond,
    };
};

module.exports = {
    checkUserExistence,
    checkKolamExistence,
};
