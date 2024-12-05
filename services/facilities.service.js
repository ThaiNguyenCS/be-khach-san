const createHttpError = require("http-errors");
const { database } = require("../database");

class FacilityService {



    async addFacility () {
        try
        {

        }
        catch(error)
        {
            throw createHttpError(500, error.message)
        }
        await database.query(`CALL CreateCoSoVatChatPhong()`)
    }

    async deleteFacility ()
    {

    }

    async updateFacility ()
    {

    }
}

module.exports = new FacilityService()