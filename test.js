function generateNumbers() {
    for (let i = 1; i <= 3; i++) { // 3 sets (101-120, 201-220, 301-320)
        const start = i * 100 + 1;
        const end = start + 20;
        for (let number = start; number < end; number++) {
            console.log(number)
        }
    }
}
generateNumbers()