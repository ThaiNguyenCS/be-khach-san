function pushUpdate (updates, fieldName, value)
{   console.log(fieldName, value);

    if(value)
    {
        updates.push(`${fieldName} = ${value}`)
    }
}

module.exports = {pushUpdate}