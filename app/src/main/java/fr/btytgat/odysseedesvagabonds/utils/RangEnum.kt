package fr.btytgat.odysseedesvagabonds.utils

enum class RangEnum(val label: String, val rangNumber: Int, val description: String?, val history: String?) {
    RANG_1_ARTILLERIE("1 - Apprenti artilleur", 1,null, null),
    RANG_2_ARTILLERIE("2 - Connon à mains", 2,null, null),
    RANG_3_ARTILLERIE("3 - Artilleur confirmé", 3,null, null),
    RANG_4_ARTILLERIE("4 - Médecin de campagne", 4,null, null),
    RANG_5_ARTILLERIE("5 - Artilleur vétéran", 5,null, null),

    RANG_1_CHIMISTE("1 - Chimiste en herbe", 1, null, null),
    RANG_2_CHIMISTE("2 - Expertise de la poudre", 2, null, null),
    RANG_3_CHIMISTE("3 - Projectile explosif", 3, null, null),
    RANG_4_CHIMISTE("4 - Démolisseur", 4, null, null),
    RANG_5_CHIMISTE("5 - Sapeur", 5, null, null),

    RANG_1_TIREUR("1 - Entrainement au tir", 1, null, null),
    RANG_2_TIREUR("2 - Tenir en joue", 2, null, null),
    RANG_3_TIREUR("3 - Pistoléro", 3, null, null),
    RANG_4_TIREUR("4 - Rechargement rapide", 4, null, null),
    RANG_5_TIREUR("5 - As de la gâchette", 5, null, null),

    RANG_1_MECANIQUE("1 - Mécanicien", 1, null, null),
    RANG_2_MECANIQUE("2 - Physique appliquée", 2, null, null),
    RANG_3_MECANIQUE("3 - Automate", 3, null, null),
    RANG_4_MECANIQUE("4 - Bidouillage", 4, null, null),
    RANG_5_MECANIQUE("5 - Golem", 5, null, null),


    RANG_1_BESTIALE("1 - Animal de compagnie", 1, null, null),
    RANG_2_BESTIALE("2 - Transformation minime", 2, null, null),
    RANG_3_BESTIALE("3 - Mutation partielle", 3, null, null),
    RANG_4_BESTIALE("4 - Animal de combat", 4, null, null),
    RANG_5_BESTIALE("5 - Transformation majeure", 5, null, null),

    RANG_1_PROTECTEUR("1 - Peau d'écorces", 1, null, null),
    RANG_2_PROTECTEUR("2 - Ecorces partagés", 2, null, null),
    RANG_3_PROTECTEUR("3 - Brume", 3, null, null),
    RANG_4_PROTECTEUR("4 - Instinct", 4, null, null),
    RANG_5_PROTECTEUR("5 - Pissenlit protecteur", 5, null, null),

    RANG_1_NATURE("1 - Enfant de la nature", 1, null, null),
    RANG_2_NATURE("2 - Calme animal", 2, null, null),
    RANG_3_NATURE("3 - Fruit de la vie", 3, null, null),
    RANG_4_NATURE("4 - Invocation animal", 4, null, null),
    RANG_5_NATURE("5 - Tempête menaçante", 5, null, null),

    RANG_1_VEGETAUX("1 - Vie sylvestre", 1, null, null),
    RANG_2_VEGETAUX("2 - Se fondre dans la nature", 2, null, null),
    RANG_3_VEGETAUX("3 - Lianes immobilisantes", 3, null, null),
    RANG_4_VEGETAUX("4 - Arbrification", 4, null, null),
    RANG_5_VEGETAUX("5 - Plante carnivore", 5, null, null),

}