document.addEventListener("DOMContentLoaded", function () {
    const dropZone = document.getElementById("drop-zone");
    const currentImage = document.getElementById("current-image");
    const hiddenInput = document.getElementById("image_filename");

    // Add drag-and-drop functionality
    document.querySelectorAll(".image-item").forEach(item => {
        item.addEventListener("dragstart", function (event) {
            // Pass the filename via dataTransfer
            event.dataTransfer.setData("filename", this.dataset.filename);
        });
    });

    dropZone.addEventListener("dragover", function (event) {
        event.preventDefault(); // Enable drop
        dropZone.style.border = "2px dashed red"; // Visual feedback
    });

    dropZone.addEventListener("dragleave", function () {
        dropZone.style.border = "none"; // Reset feedback
    });

    dropZone.addEventListener("drop", function (event) {
        event.preventDefault();
        dropZone.style.border = "none"; // Reset border

        const filename = event.dataTransfer.getData("filename");
        if (filename) {
            // Update image preview and hidden input
            currentImage.src = `/img/${filename}`;
            hiddenInput.value = filename;
            console.log("Dropped filename:", filename); // Debug
        }
    });
});


function updateCartCount() {
    const cartCount = document.getElementById("cart-count");
    fetch('/cart_count')
    .then(response => response.json())
    .then(data => {
        cartCount.textContent = data.count;
    });
}

updateCartCount();
