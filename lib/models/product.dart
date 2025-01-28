class Product {
  final int id, price;
  final String title, description, image;
  final String model;
  final String category; // Add this line

  Product({
    required this.id,
    required this.price,
    required this.title,
    required this.description,
    required this.image,
    required this.model,
    required this.category, // Add this
  });
}

// List of products for the demo
List<Product> products = [
  Product(
    id: 1,
    price: 3598,
    title:
        "Bhumika Overseas Eames Replica Faux Leather Medium Dining Chair (Black)",
    image: "assets/images/chair1.png",
    description:
        "Product Dimensions:- Height: (28.0 inches) X Width: (19.0 inches) X Diameter: 15.0 (inches) Main Material: Faux Leather, Upholstery Material: Leatherette Leg Material: Beech Wood Combined with elements of black metal Upholstered: Yes, with characteristic pattern of triangles; Wood Construction Type: Solid Wood Weight Capacity: 100 Kgs; Back Style: Solid Back The dining side chair is a sweet velour seat. Modern meets mod in the shape and metal crossing at the wood legs",
    model: 'https://example.com/models/sofa.gltf',
    category: "Armchair",
  ),
  Product(
    id: 4,
    price: 16999,
    title: "Home Centre Helios Vive 3 Seater Sofa - Grey",
    image: "assets/images/sofa1.jpg",
    description:
        "Dimension : 3 Seater Sofa, 187 cm x 85 cm x 93 cm Polyester Soft Touch Fabric: Anti Microbial, Anti Allergic, both spot cleaning and shampooing recommended for longer life. FRAME: Pinewood .Pretreated against moisture and wood infestation, pine wood is stable, elastic and light weight, which is economical yet durable and used widely for sofa frame construction. Mild steel legs are provided extra leg provided for extra support",
    model: 'https://example.com/models/sofa.gltf',
    category: "Sofa",
  ),
  Product(
    id: 9,
    price: 3029,
    title:
        "Finch Fox Polypropylene, Faux-Leather, Wood Eames Replica Nordan Iconic Chair in Grey Colour",
    image: "assets/images/chair2.jpg",
    description:
        "The seat and backrest of the chair is made of high quality polypropylene. The stability and durability of the structure is ensured by beech wood legs, which also give it a unique character. An additional advantage is also a seat lined with a soft sponge and covered with artificial leather, providing even greater comfort of its use.",
    model: 'https://example.com/models/sofa.gltf',
    category: "Armchair",
  ),
  Product(
    id: 10,
    price: 22775,
    title:
        "Solid Sal Wood Fabric Upholstered 2 Seater Sofa Set for Living Room, Green Color",
    image: "assets/images/sofa2.png",
    description:
        "2 Seater Sofa Set Dimensions - Length : 60, Width : 33, Height : 34, , Seating Height : 18 , Seating Height (From ground to seat) : 18 (All Dimensions are in inches) The seat construction comes with elastic webbing belt suspension with 4 inch thick 40 density foam seat filling material & Upholstery Material is Fabric The frame of the sofa is made from treated solid Sal wood, which is a high-quality and durable material. The secondary frame material is made from 18 mm ply wood, which makes the sofa sturdy and stable.",
    model: 'https://example.com/models/sofa.gltf',
    category: "Sofa",
  ),
  Product(
    id: 12,
    price: 6490,
    title:
        "Vergo Plush Dining Chair Accent Chair for Living Room Bedroom Restuarant",
    image: "assets/images/chair3.jpg",
    description:
        "Premium Velvet Upholstery - The soft and luxurious velvet fabric with the fine stitch detail on the back that really elevates the overall look. Our Plush Dining Chair is designed to add a touch of luxury and comfort to your dining space.  Spacious Seating & Armrest - The wide spacious Seating area with thick Padding provides support to your thighs and also allows user to sit cross legged & the armrests help to relax & sit comfortably.  Strong Structure - Built on durable Wooden Frame & Heavy Duty Metal legs for stability and Rose Gold finish for enhanced look. The legpads to protect the floor from scratching; and anti-noise features won’t add the noise when you are enjoying the happy dinner time.",
    model: 'assets/models/Midnight_Chair_1030105619.glb',
    category: "Armchair",
  
  ),
  Product(
    id: 14,
    price: 6999,
    title:
        "Westido Orlando Leatherette 2-Person Sofa (Finish Color - Matte Brown, (Diy-Do-It-Yourself)",
    image: "assets/images/sofa3.jpg",
    description:
        "Comfortable seating: The sofa features generously padded seats and backrests, making it comfortable for extended periods of sitting. Stylish design: The sofa has a modern and elegant design that can complement various home dcor styles. Space-saving: The sofa has a compact size that is ideal for small spaces, such as apartments or dorm rooms. Versatile use: The sofa can be used in different settings, such as living rooms, guest rooms, or home offices, depending on your needs.",
    model: 'assets/models/Cozy_Living_Room_1030102917.glb',
    category: "Sofa",
  ),
];
