// Hobby popup behaviour — kept in a separate file so the template stays markup-only.

document.addEventListener("DOMContentLoaded", () => {
    const modal = document.getElementById("hobby-modal");
    const modalTitle = document.getElementById("hobby-modal-title");
    const modalGallery = document.getElementById("hobby-modal-gallery");
    const modalContent = modal?.querySelector(".hobby-modal-content");

    if (!modal || !modalTitle || !modalGallery || !modalContent) {
        return;
    }

    // Must match the CSS transition duration so content is cleared after the close animation.
    const ANIMATION_MS = 250;

    const openModal = (name, gallery) => {
        modalTitle.textContent = name;
        modalGallery.innerHTML = "";

        gallery.forEach((imageUrl) => {
            const image = document.createElement("img");
            image.src = imageUrl;
            image.alt = `${name} photo`;
            image.loading = "lazy";
            modalGallery.appendChild(image);
        });

        modal.setAttribute("aria-hidden", "false");
        // Prevent scrolling the page behind the popup while it is open.
        document.body.style.overflow = "hidden";

        // Defer the open class by one frame so the CSS transition actually runs.
        requestAnimationFrame(() => {
            modal.classList.add("is-open");
        });
    };

    const closeModal = () => {
        modal.classList.remove("is-open");
        modal.classList.add("is-closing");

        window.setTimeout(() => {
            modal.classList.remove("is-closing");
            modal.setAttribute("aria-hidden", "true");
            modalGallery.innerHTML = "";
            document.body.style.overflow = "";
        }, ANIMATION_MS);
    };

    document.querySelectorAll(".hobby-card").forEach((card) => {
        card.addEventListener("click", () => {
            const name = card.dataset.hobbyName;
            const gallery = JSON.parse(card.dataset.gallery || "[]");
            openModal(name, gallery);
        });
    });

    modal.querySelectorAll("[data-modal-close]").forEach((element) => {
        element.addEventListener("click", closeModal);
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && modal.classList.contains("is-open")) {
            closeModal();
        }
    });
});
