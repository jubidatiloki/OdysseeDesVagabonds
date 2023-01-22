package fr.btytgat.odysseedesvagabonds.utils

enum class ClasseEnum(val label: String, val healthDiceModifier: Int, val manaDiceModifier: Int, val description: String, val history: String) {
    BARBARE("Barbare", 1, -1, "aime se battre, beaucoup et vraiment tout le temps, pour tout", "homme de cromagnon avec la rage en quelque sorte"),
    BARDE("Barde", 0, 0, "aime faire de la musique", "a commencer lorsque les gens s'ennuyaient"),
    CHEVALIER("Chevalier", 1, -1, "aime les belles armures", "vis dans un chateau"),
    DRUIDE("Druide", 0, 1, "baise des arbres et des animaux de façon légale", "PEGI 18"),
    GUERRIER("Guerrier", 1, -1, "est capable de se battre avec tout, genre un crayon, ou katana", ""),
    INGENIEUR("Ingénieur", 1, -1, "sait lire, écrire, compter, faire des calcul et utiliser une baliste d'une demi-tonne", "trust me i'm an engineer"),
    MAGICIEN("Magicien", -1, 1, "sait faire mumuse avec la magie", "rat de bibliothèque"),
    MOINE("Moine", 1, 0, "savait marcher sur l'eau avant que ca devienne à la mode", "vis nu la plupart du temps et \"médite\" souvent les lendemain de cuite"),
    NECROMANCIEN("Nécromancien", -1, 1, "fait revivre les morts", "vis dans un cimetière par soucis de transport de matière première"),
    PRETRE("Prêtre", 0, 1, "est schyzophrene et fait croire a tout le monde que c'est son dieu qui lui parle", "s'est trouvé un ami imaginaire"),
    RODEUR("Rodeur", 0, 0, "chasseur qui se donne des air cool", "pew, pew, pew"),
    VOLEUR("Voleur", 0, 0, "petite tendance cleptomane", "vole, mais pas comme superman")
}