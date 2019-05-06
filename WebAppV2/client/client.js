let picture = document.querySelector("#pictures");

if (picture) {
    fetch('/images')
        .then(res => res.json())
        .then(res => {
            res.forEach(image => {
                console.log(image)
                const img = document.createElement('img');
                img.src = '${image}'
                picture.appendChild(img)
            });
        })
}