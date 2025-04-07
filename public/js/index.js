const data =[
    {
        itemName: "Horror",
        itemCategory: "Horror genre",
        itemLink: "#",
        itemCopy:
        "Horror movies are a type of film that aims to scare, unsettle, or terrify audiences. They often feature suspenseful storytelling, disturbing imagery, and eerie sound effects to evoke fear. Common themes include supernatural elements, psychological horror, and subgenres like slasher films and body horror. Horror movies explore societal fears, confront mortality, and provide cathartic experiences for viewers.",
        itemImg:"/img/horror.jpg",
    },
    {
        itemName:"Action",
        itemCategory:"Action genre",
        itemLink: "#",
        itemCopy:
        "Action movies are fast-paced films filled with thrilling stunts, intense fights, and explosive action sequences. They feature heroic characters facing off against villains or overcoming challenges. Common elements include car chases, martial arts fights, and gun battles. Action movies entertain audiences with their adrenaline-pumping excitement and themes of courage and triumph.",
        itemImg:"/img/action.jpg",

    },
    {
        itemName: "Drama",
        itemCategory: "Drama",
        itemLink:"#",
        itemCopy:
        "Drama movies focus on realistic storytelling and character development, often exploring complex themes such as love, family dynamics, or societal issues. They evoke emotional responses from viewers through compelling narratives and nuanced performances.",
        itemImg: "/img/Drama.jpg",
    },
    {
        itemName: "Comedy",
        itemCategory: "Comedy",
        itemLink: "#",
        itemCopy:
        "Comedy movies aim to entertain and provoke laughter through humor and wit. They often rely on funny situations, clever dialogue, and comedic timing to engage audiences and provide lighthearted entertainment.",
        itemImg: "/img/comedy.jpg",
    },
    {
        itemName: "Romance",
        itemCategory: "Romance",
        itemLink: "#",
        itemCopy: "Romance movies center around romantic relationships and love stories between characters. They evoke emotions such as affection, passion, and longing, often featuring themes of love overcoming obstacles or finding happiness against the odds.",
        itemImg: "/img/romance.jpg",
    },
    {
        itemName: "Sciencefiction",
        itemCategory: "Science Fiction",
        itemLink: "#",
        itemCopy: "Science fiction movies explore speculative concepts, futuristic settings, and advanced technologies. They often delve into themes such as space exploration, time travel, or the impact of scientific advancements on society. Science fiction movies captivate audiences with imaginative worlds and thought-provoking ideas.",
        itemImg: "/img/science_fiction.jpg",
    },
    {
        itemName:"Thriller",
        itemCategory:"Thriller",
        itemLink: "#",
        itemCopy: "Thriller movies are suspenseful films that keep audiences on the edge of their seats with tension, anticipation, and unexpected twists. They typically feature intense plots, thrilling action sequences, and psychological suspense, often involving characters facing dangerous situations or pursuing elusive mysteries. Thriller movies aim to keep viewers engaged and guessing until the very end.",
        itemImg:"/img/thriller.webp",
    },
    {
        itemName:"Animation",
        itemCategory:"Animation",
        itemLink: "#",
        itemCopy: "Animation movies bring characters and stories to life through the art of animation, utilizing techniques such as traditional hand-drawn animation, computer-generated imagery (CGI), or stop-motion animation. They appeal to audiences of all ages with colorful visuals, imaginative worlds, and engaging storytelling. Animation movies span various genres, including family-friendly adventures, fantastical tales, and thought-provoking dramas.",
        itemImg:"/img/animation.jpg",
    },
    {
        itemName:"Mystery",
        itemCategory:"Mystery",
        itemLink: "#",
        itemCopy: "Mystery movies center around enigmatic puzzles, unsolved crimes, or mysterious occurrences that intrigue characters and audiences alike. They feature twists and turns, clues, and revelations as characters strive to uncover the truth behind perplexing mysteries. Mystery movies often blend elements of suspense, thriller, and detective genres, keeping viewers engaged as they unravel the secrets hidden within the story.",
        itemImg:"/img/mystery.jpg",
    },
    {
        itemName:"Crime",
        itemCategory:"Crime",
        itemLink: "#",
        itemCopy: "Crime movies focus on criminal activities, investigations, and the pursuit of justice. They often feature complex plots, morally ambiguous characters, and tense showdowns between law enforcement and criminals. Crime movies may explore themes such as corruption, redemption, and the consequences of illegal actions, captivating audiences with their suspenseful narratives and gritty realism.",
        itemImg:"/img/crime.jpg",
    },
];


 const overlay = document.querySelector(".overlay");
 const closeBtn = document.querySelector("#close-btn");

 const tl = gsap.timeline({ paused: true, overwrite:
"auto"});

tl.to(overlay, {
    duration: 0.5,
    bottom: "0px",
    opacity: 1,
    height: "100vh",
});

const item = document.querySelectorAll(".item");
item.forEach((item, index) => {
    item.addEventListener("click", () => {
        updateOverlay(data[index]);

        tl.play();
    });
});

closeBtn.addEventListener("click", () => {
    tl.reverse();
});

function updateOverlay(dataItem) {
    const itemName = 
    document.querySelector("#item-category").
    previousElementSibling;
    const itemCategory = document.querySelector
    ("#item-category");
    const itemLink = document.querySelector("#item-link");
    const itemCopy = document.querySelector("#item-copy");
    const itemImg = document.querySelector("#item-img");

    itemName.textContent = dataItem.itemName;
    itemCategory.textContent = dataItem.itemCategory;
    itemLink.href = dataItem.itemLink;
    itemCopy.textContent = dataItem.itemCopy;
    itemImg.src = dataItem.itemImg;
}

document.addEventListener("click", (e) => {
    if(!overlay.contains(e.target) && !isItem(e.target)) {
        tl.reverse();
    }
});

function isItem(target) {
    return target.closest(".item");
};

/*Navigation */

const primaryNav = document.querySelector(".primary-navigation");
const navToggle = document.querySelector(".mobile-nav-toggle");

navToggle.addEventListener('click', (event) => {

    event.stopPropagation();

    const visibility = primaryNav.getAttribute('data-visible')

    if (visibility === "false"){
        primaryNav.setAttribute('data-visible', true);
    } else if (visibility === "true") {
        primaryNav.setAttribute('data-visible', false)
    }
});


/* Nav-Button*/

function myFunction(x) {
    x.classList.toggle("change");
}
