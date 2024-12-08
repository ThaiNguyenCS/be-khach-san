function handleParameterIfNull(value) {
    if (value && typeof value === "string") {
        return `"${value}"`;
    }
    if (value && typeof value === "number") {
        return parseFloat(value);
    }
 
    return null;
}

module.exports = { handleParameterIfNull };
