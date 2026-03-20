// data/curriculum_data.dart
// 100 % offline — all content is hardcoded here.
// Add / edit subjects & chapters without touching any other file.

import '../models/curriculum_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MASTER CURRICULUM MAP
// Key format: '<BOARD>|<CLASS>'   e.g. 'CBSE|Class 10'
// ─────────────────────────────────────────────────────────────────────────────
class CurriculumData {
  CurriculumData._();

  // ── Public API ─────────────────────────────────────────────────────────────
  static List<Subject> getSubjects(String board, String className) {
    final key = '${board.toUpperCase()}|$className';
    return _data[key] ?? _defaultSubjects(className);
  }

  // ── Fallback: generate generic subjects when exact mapping missing ──────────
  static List<Subject> _defaultSubjects(String className) {
    final classNum = int.tryParse(
          className.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        1;

    final common = <Subject>[
      _maths(classNum),
      _english(classNum),
      _evs(classNum),
    ];

    if (classNum >= 6) common.add(_science(classNum));
    if (classNum >= 6) common.add(_socialScience(classNum));
    if (classNum >= 8) common.add(_hindi(classNum));
    if (classNum >= 9) common.add(_computer(classNum));

    return common;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATA MAP
  // ─────────────────────────────────────────────────────────────────────────
  static final Map<String, List<Subject>> _data = {

    // ══════════════════════════════════════════════════════════════════
    // CBSE
    // ══════════════════════════════════════════════════════════════════

    'CBSE|Class 10': [
      Subject(
        id: 'cbse10_maths',
        name: 'Maths',
        emoji: '🔢',
        chapters: [
          Chapter(
            id: 'c10m1', title: 'Real Numbers',
            description: 'Fundamental theorem of arithmetic and irrational numbers.',
            topics: ['Euclid\'s Division Lemma', 'HCF & LCM', 'Irrational Numbers', 'Decimal Expansions'],
          ),
          Chapter(
            id: 'c10m2', title: 'Polynomials',
            description: 'Zeroes of polynomials and division algorithm.',
            topics: ['Geometrical Meaning of Zeroes', 'Relationship Between Zeroes & Coefficients', 'Division Algorithm'],
          ),
          Chapter(
            id: 'c10m3', title: 'Pair of Linear Equations',
            description: 'Graphical and algebraic methods of solving.',
            topics: ['Graphical Method', 'Substitution', 'Elimination', 'Cross-Multiplication'],
          ),
          Chapter(
            id: 'c10m4', title: 'Quadratic Equations',
            description: 'Roots, discriminant and applications.',
            topics: ['Factorisation', 'Completing the Square', 'Quadratic Formula', 'Nature of Roots'],
          ),
          Chapter(
            id: 'c10m5', title: 'Arithmetic Progressions',
            description: 'nth term and sum of AP.',
            topics: ['General Term', 'Sum of First n Terms', 'Word Problems'],
          ),
          Chapter(
            id: 'c10m6', title: 'Triangles',
            description: 'Similarity criteria and Pythagoras theorem.',
            topics: ['Basic Proportionality Theorem', 'AAA, SSS, SAS Similarity', 'Pythagoras Theorem'],
          ),
          Chapter(
            id: 'c10m7', title: 'Coordinate Geometry',
            description: 'Distance, section formula and area.',
            topics: ['Distance Formula', 'Section Formula', 'Area of Triangle'],
          ),
          Chapter(
            id: 'c10m8', title: 'Introduction to Trigonometry',
            description: 'Trigonometric ratios and identities.',
            topics: ['Ratios of Acute Angles', 'Trigonometric Identities', 'Complementary Angles'],
          ),
          Chapter(
            id: 'c10m9', title: 'Some Applications of Trigonometry',
            description: 'Heights and distances.',
            topics: ['Angle of Elevation', 'Angle of Depression', 'Problems on Heights & Distances'],
          ),
          Chapter(
            id: 'c10m10', title: 'Circles',
            description: 'Tangent properties.',
            topics: ['Tangent to a Circle', 'Number of Tangents from a Point'],
          ),
          Chapter(
            id: 'c10m11', title: 'Areas Related to Circles',
            description: 'Perimeter and area of sectors.',
            topics: ['Perimeter & Area of Circle', 'Areas of Sectors & Segments'],
          ),
          Chapter(
            id: 'c10m12', title: 'Surface Areas and Volumes',
            description: 'Combined solids and frustum.',
            topics: ['Combination of Solids', 'Conversion of Solids', 'Frustum of a Cone'],
          ),
          Chapter(
            id: 'c10m13', title: 'Statistics',
            description: 'Mean, median and mode of grouped data.',
            topics: ['Mean', 'Median', 'Mode', 'Cumulative Frequency'],
          ),
          Chapter(
            id: 'c10m14', title: 'Probability',
            description: 'Classical probability.',
            topics: ['Basic Events', 'Complementary Events', 'Word Problems'],
          ),
        ],
      ),
      Subject(
        id: 'cbse10_sci',
        name: 'Science',
        emoji: '🧪',
        chapters: [
          Chapter(id: 'c10s1', title: 'Chemical Reactions & Equations', description: 'Types of chemical reactions.', topics: ['Balancing Equations', 'Combination Reaction', 'Decomposition', 'Displacement', 'Redox']),
          Chapter(id: 'c10s2', title: 'Acids, Bases and Salts', description: 'Properties and reactions.', topics: ['Indicators', 'pH Scale', 'Neutralisation', 'Salts & their Uses']),
          Chapter(id: 'c10s3', title: 'Metals and Non-metals', description: 'Physical & chemical properties.', topics: ['Properties', 'Reactivity Series', 'Extraction of Metals', 'Corrosion']),
          Chapter(id: 'c10s4', title: 'Carbon and Its Compounds', description: 'Organic chemistry basics.', topics: ['Covalent Bonding', 'Saturated & Unsaturated Carbon', 'Nomenclature', 'Chemical Properties']),
          Chapter(id: 'c10s5', title: 'Life Processes', description: 'Nutrition, respiration, transport.', topics: ['Nutrition in Plants & Animals', 'Respiration', 'Transportation', 'Excretion']),
          Chapter(id: 'c10s6', title: 'Control and Coordination', description: 'Nervous & endocrine system.', topics: ['Nervous System', 'Reflex Action', 'Endocrine System', 'Plant Hormones']),
          Chapter(id: 'c10s7', title: 'Reproduction', description: 'Types of reproduction.', topics: ['Asexual Reproduction', 'Sexual Reproduction', 'Reproductive Health']),
          Chapter(id: 'c10s8', title: 'Heredity and Evolution', description: 'Mendel\'s laws and evolution theory.', topics: ['Mendel\'s Experiments', 'Acquired & Inherited Traits', 'Evolution', 'Human Evolution']),
          Chapter(id: 'c10s9', title: 'Light – Reflection & Refraction', description: 'Mirror and lens formula.', topics: ['Reflection', 'Mirror Formula', 'Refraction', 'Lens Formula', 'Power of Lens']),
          Chapter(id: 'c10s10', title: 'Human Eye and Colourful World', description: 'Defects and dispersion.', topics: ['Structure of Eye', 'Defects of Vision', 'Atmospheric Refraction', 'Dispersion']),
          Chapter(id: 'c10s11', title: 'Electricity', description: 'Ohm\'s law and electric circuits.', topics: ['Ohm\'s Law', 'Resistance', 'Series & Parallel Circuits', 'Heating Effect']),
          Chapter(id: 'c10s12', title: 'Magnetic Effects of Electric Current', description: 'Motors and generators.', topics: ['Magnetic Field', 'Electromagnetism', 'Electric Motor', 'Generator', 'Domestic Circuits']),
          Chapter(id: 'c10s13', title: 'Our Environment', description: 'Ecosystem and waste management.', topics: ['Ecosystem', 'Food Chain & Web', 'Ozone Layer', 'Waste Management']),
        ],
      ),
      Subject(
        id: 'cbse10_eng',
        name: 'English',
        emoji: '📖',
        chapters: [
          Chapter(id: 'c10e1', title: 'A Letter to God', description: 'Faith and resilience.', topics: ['Summary', 'Character Sketch', 'Themes', 'Important Questions']),
          Chapter(id: 'c10e2', title: 'Nelson Mandela: Long Walk to Freedom', description: 'Autobiography excerpt.', topics: ['Summary', 'Values Depicted', 'Vocabulary', 'Important Questions']),
          Chapter(id: 'c10e3', title: 'Two Stories about Flying', description: 'His First Flight & Black Aeroplane.', topics: ['Summary', 'Comparison', 'Moral', 'Important Questions']),
          Chapter(id: 'c10e4', title: 'From the Diary of Anne Frank', description: 'Holocaust diary excerpt.', topics: ['Summary', 'Character', 'Historical Context', 'Questions']),
          Chapter(id: 'c10e5', title: 'Writing Skills', description: 'Formal & informal writing.', topics: ['Letter Writing', 'Email', 'Notice', 'Article Writing', 'Story Writing']),
          Chapter(id: 'c10e6', title: 'Grammar', description: 'Key grammar topics.', topics: ['Tenses', 'Modals', 'Subject–Verb Agreement', 'Reported Speech', 'Connectors']),
        ],
      ),
      Subject(
        id: 'cbse10_sst',
        name: 'History',
        emoji: '🏛️',
        chapters: [
          Chapter(id: 'c10h1', title: 'The Rise of Nationalism in Europe', description: 'Nation-states and revolutions.', topics: ['French Revolution', 'Napoleonic Code', 'Conservative Order', 'Nation-States']),
          Chapter(id: 'c10h2', title: 'Nationalism in India', description: 'Non-cooperation and Civil Disobedience.', topics: ['Non-Cooperation Movement', 'Civil Disobedience', 'Sense of Collective Belonging']),
          Chapter(id: 'c10h3', title: 'The Making of a Global World', description: 'Trade and globalization.', topics: ['Pre-modern World', 'Colonialism', 'Interwar Economy', 'Bretton Woods']),
          Chapter(id: 'c10h4', title: 'The Age of Industrialisation', description: 'Industrial revolution.', topics: ['Proto-Industrialisation', 'Industrial Revolution in Britain', 'Industrialisation in India']),
          Chapter(id: 'c10h5', title: 'Print Culture and the Modern World', description: 'Rise of print media.', topics: ['Print Revolution', 'Print in Europe', 'Print & Nationalism in India']),
        ],
      ),
      Subject(
        id: 'cbse10_geo',
        name: 'Geography',
        emoji: '🌍',
        chapters: [
          Chapter(id: 'c10g1', title: 'Resources and Development', description: 'Types and conservation.', topics: ['Classification of Resources', 'Land Use', 'Soil', 'Conservation']),
          Chapter(id: 'c10g2', title: 'Forest and Wildlife Resources', description: 'Biodiversity conservation.', topics: ['Flora & Fauna', 'Depletion Causes', 'Conservation Projects']),
          Chapter(id: 'c10g3', title: 'Water Resources', description: 'Management and conservation.', topics: ['Water Scarcity', 'Dams', 'Rainwater Harvesting']),
          Chapter(id: 'c10g4', title: 'Agriculture', description: 'Types of farming.', topics: ['Types of Farming', 'Major Crops', 'Contribution to Economy', 'Agricultural Reforms']),
          Chapter(id: 'c10g5', title: 'Minerals and Energy Resources', description: 'Extraction and use.', topics: ['Metallic & Non-metallic Minerals', 'Conventional Energy', 'Non-conventional Energy']),
        ],
      ),
      Subject(
        id: 'cbse10_comp',
        name: 'Computer',
        emoji: '💻',
        chapters: [
          Chapter(id: 'c10comp1', title: 'Introduction to Python', description: 'Basics of Python programming.', topics: ['Variables & Data Types', 'Operators', 'Input / Output', 'Conditional Statements', 'Loops']),
          Chapter(id: 'c10comp2', title: 'Functions & Modules', description: 'Reusable code blocks.', topics: ['Defining Functions', 'Arguments', 'Return Values', 'Standard Library Modules']),
          Chapter(id: 'c10comp3', title: 'Strings & Lists', description: 'Sequence data types.', topics: ['String Methods', 'List Operations', 'Slicing', 'List Comprehension']),
          Chapter(id: 'c10comp4', title: 'Cyber Safety', description: 'Internet safety and ethics.', topics: ['Cyber Crime', 'Cyber Laws', 'Safe Online Practices', 'Digital Footprint']),
        ],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════
    // CBSE Class 9
    // ══════════════════════════════════════════════════════════════════
    'CBSE|Class 9': [
      Subject(
        id: 'cbse9_maths',
        name: 'Maths',
        emoji: '🔢',
        chapters: [
          Chapter(id: 'c9m1', title: 'Number Systems', description: 'Real numbers and surds.', topics: ['Rational Numbers', 'Irrational Numbers', 'Laws of Exponents']),
          Chapter(id: 'c9m2', title: 'Polynomials', description: 'Types and factor theorem.', topics: ['Degrees of Polynomials', 'Remainder Theorem', 'Factor Theorem', 'Algebraic Identities']),
          Chapter(id: 'c9m3', title: 'Coordinate Geometry', description: 'Cartesian plane basics.', topics: ['Cartesian Plane', 'Plotting Points', 'Quadrants']),
          Chapter(id: 'c9m4', title: 'Linear Equations in Two Variables', description: 'Graph and solutions.', topics: ['Solutions of Linear Equations', 'Graphical Method']),
          Chapter(id: 'c9m5', title: 'Lines and Angles', description: 'Theorems on angles.', topics: ['Intersecting Lines', 'Parallel Lines', 'Angle Sum Property']),
          Chapter(id: 'c9m6', title: 'Triangles', description: 'Congruence criteria.', topics: ['SAS, ASA, SSS, RHS', 'Inequalities in Triangle']),
          Chapter(id: 'c9m7', title: 'Heron\'s Formula', description: 'Area of scalene triangle.', topics: ['Area Using Heron\'s Formula', 'Area of Quadrilateral']),
          Chapter(id: 'c9m8', title: 'Surface Areas and Volumes', description: 'Basic 3D solids.', topics: ['Cuboid', 'Cylinder', 'Cone', 'Sphere']),
          Chapter(id: 'c9m9', title: 'Statistics', description: 'Data representation.', topics: ['Collection of Data', 'Bar Graph', 'Histogram', 'Frequency Polygon', 'Mean, Median, Mode']),
        ],
      ),
      Subject(
        id: 'cbse9_sci',
        name: 'Science',
        emoji: '🧪',
        chapters: [
          Chapter(id: 'c9s1', title: 'Matter in Our Surroundings', description: 'States of matter.', topics: ['Solid, Liquid, Gas', 'Evaporation', 'Interconversion']),
          Chapter(id: 'c9s2', title: 'Is Matter Around Us Pure?', description: 'Mixtures and compounds.', topics: ['Pure Substances', 'Mixtures', 'Separation Techniques', 'Solutions']),
          Chapter(id: 'c9s3', title: 'Atoms and Molecules', description: 'Laws of chemical combination.', topics: ['Laws of Chemical Combination', 'Atoms', 'Molecules', 'Mole Concept']),
          Chapter(id: 'c9s4', title: 'Structure of the Atom', description: 'Atomic models.', topics: ['Thomson\'s Model', 'Rutherford\'s Model', 'Bohr\'s Model', 'Valency']),
          Chapter(id: 'c9s5', title: 'The Fundamental Unit of Life', description: 'Cell structure.', topics: ['Cell Theory', 'Prokaryotic vs Eukaryotic', 'Cell Organelles']),
          Chapter(id: 'c9s6', title: 'Tissues', description: 'Plant and animal tissues.', topics: ['Meristematic Tissue', 'Permanent Tissue', 'Animal Tissues']),
          Chapter(id: 'c9s7', title: 'Motion', description: 'Kinematics basics.', topics: ['Displacement', 'Velocity', 'Acceleration', 'Equations of Motion', 'Graphs']),
          Chapter(id: 'c9s8', title: 'Force and Laws of Motion', description: 'Newton\'s laws.', topics: ['Newton\'s 1st, 2nd, 3rd Law', 'Momentum', 'Conservation of Momentum']),
          Chapter(id: 'c9s9', title: 'Gravitation', description: 'Universal law of gravitation.', topics: ['Law of Gravitation', 'Free Fall', 'Mass & Weight', 'Pressure', 'Archimedes\' Principle']),
          Chapter(id: 'c9s10', title: 'Work and Energy', description: 'Work-energy theorem.', topics: ['Work Done', 'Kinetic & Potential Energy', 'Law of Conservation of Energy', 'Power']),
          Chapter(id: 'c9s11', title: 'Sound', description: 'Wave nature of sound.', topics: ['Propagation', 'Characteristics', 'Reflection of Sound', 'Ultrasound']),
        ],
      ),
      Subject(
        id: 'cbse9_eng',
        name: 'English',
        emoji: '📖',
        chapters: [
          Chapter(id: 'c9e1', title: 'The Fun They Had', description: 'Isaac Asimov\'s story on future schools.', topics: ['Summary', 'Theme', 'Characters', 'Important Questions']),
          Chapter(id: 'c9e2', title: 'The Sound of Music', description: 'Two musicians\' inspiring stories.', topics: ['Part I – Evelyn Glennie', 'Part II – Bismillah Khan', 'Questions']),
          Chapter(id: 'c9e3', title: 'Grammar', description: 'Core grammar.', topics: ['Tenses', 'Articles', 'Prepositions', 'Reported Speech', 'Active/Passive']),
          Chapter(id: 'c9e4', title: 'Writing Skills', description: 'Formal writing formats.', topics: ['Notice Writing', 'Letter Writing', 'Diary Entry', 'Descriptive Paragraphs']),
        ],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════
    // SSC Class 10
    // ══════════════════════════════════════════════════════════════════
    'SSC|Class 10': [
      Subject(
        id: 'ssc10_maths1',
        name: 'Maths I',
        emoji: '🔢',
        chapters: [
          Chapter(id: 'ssc10m1_1', title: 'Linear Equations in Two Variables', description: 'Graph and simultaneous equations.', topics: ['Graphical Method', 'Algebraic Method', 'Word Problems']),
          Chapter(id: 'ssc10m1_2', title: 'Quadratic Equations', description: 'Factorisation & formula.', topics: ['Completing the Square', 'Quadratic Formula', 'Nature of Roots']),
          Chapter(id: 'ssc10m1_3', title: 'Arithmetic Progression', description: 'Sequences and series.', topics: ['nth Term', 'Sum of AP', 'Applications']),
          Chapter(id: 'ssc10m1_4', title: 'Financial Planning', description: 'GST, shares and investments.', topics: ['GST Calculation', 'Shares & Dividends', 'Mutual Funds Basics']),
          Chapter(id: 'ssc10m1_5', title: 'Probability', description: 'Classical definition.', topics: ['Sample Space', 'Events', 'Problems on Probability']),
          Chapter(id: 'ssc10m1_6', title: 'Statistics', description: 'Measures of central tendency.', topics: ['Mean', 'Median', 'Mode', 'Ogive']),
        ],
      ),
      Subject(
        id: 'ssc10_maths2',
        name: 'Maths II',
        emoji: '📐',
        chapters: [
          Chapter(id: 'ssc10m2_1', title: 'Similarity', description: 'Basic proportionality theorem.', topics: ['Basic Proportionality Theorem', 'Similarity Criteria', 'Applications']),
          Chapter(id: 'ssc10m2_2', title: 'Pythagoras Theorem', description: 'Proof and applications.', topics: ['Proof', 'Converse', 'Applications in Problems']),
          Chapter(id: 'ssc10m2_3', title: 'Circle', description: 'Tangent and chord properties.', topics: ['Chord Properties', 'Tangent–Radius', 'Tangent from External Point']),
          Chapter(id: 'ssc10m2_4', title: 'Geometric Constructions', description: 'Constructions using compass.', topics: ['Division of Line Segment', 'Tangent to Circle', 'Triangle Constructions']),
          Chapter(id: 'ssc10m2_5', title: 'Co-ordinate Geometry', description: 'Distance and section formula.', topics: ['Distance Formula', 'Section Formula', 'Slope']),
          Chapter(id: 'ssc10m2_6', title: 'Trigonometry', description: 'Ratios, identities and heights.', topics: ['Trigonometric Ratios', 'Identities', 'Heights & Distances']),
          Chapter(id: 'ssc10m2_7', title: 'Mensuration', description: 'Area and volume of 3D figures.', topics: ['Cylinder', 'Cone', 'Sphere', 'Frustum', 'Combination of Solids']),
        ],
      ),
      Subject(
        id: 'ssc10_sci1',
        name: 'Science I',
        emoji: '🧪',
        chapters: [
          Chapter(id: 'ssc10s1_1', title: 'Gravitation', description: 'Kepler\'s laws and gravitational force.', topics: ['Kepler\'s Laws', 'Newton\'s Law of Gravitation', 'Free Fall', 'Satellites']),
          Chapter(id: 'ssc10s1_2', title: 'Periodic Classification of Elements', description: 'Mendeleev and modern periodic table.', topics: ['Mendeleev\'s Periodic Table', 'Modern Periodic Table', 'Periodic Trends']),
          Chapter(id: 'ssc10s1_3', title: 'Chemical Reactions and Equations', description: 'Types and balancing.', topics: ['Types of Reactions', 'Balancing Equations', 'Oxidation & Reduction']),
          Chapter(id: 'ssc10s1_4', title: 'Effects of Electric Current', description: 'Magnetic effect and motor.', topics: ['Magnetic Effect', 'Motor & Generator Principle', 'Heating Effect']),
          Chapter(id: 'ssc10s1_5', title: 'Heat', description: 'Transfer of heat.', topics: ['Conduction', 'Convection', 'Radiation', 'Greenhouse Effect']),
          Chapter(id: 'ssc10s1_6', title: 'Refraction of Light', description: 'Lenses and optical devices.', topics: ['Laws of Refraction', 'Lenses', 'Lens Formula', 'Optical Instruments']),
          Chapter(id: 'ssc10s1_7', title: 'Lenses', description: 'Convex and concave lenses.', topics: ['Image Formation', 'Magnification', 'Applications']),
        ],
      ),
      Subject(
        id: 'ssc10_sci2',
        name: 'Science II',
        emoji: '🌿',
        chapters: [
          Chapter(id: 'ssc10s2_1', title: 'Life Processes in Living Organisms', description: 'Nutrition to excretion.', topics: ['Nutrition', 'Respiration', 'Transportation', 'Excretion']),
          Chapter(id: 'ssc10s2_2', title: 'Control and Coordination', description: 'Nervous and endocrine.', topics: ['Nervous System', 'Brain', 'Reflex', 'Endocrine System']),
          Chapter(id: 'ssc10s2_3', title: 'Reproduction', description: 'Asexual & sexual reproduction.', topics: ['Asexual Methods', 'Vegetative Propagation', 'Sexual Reproduction in Plants & Animals']),
          Chapter(id: 'ssc10s2_4', title: 'Heredity and Evolution', description: 'Mendel\'s laws.', topics: ['Mendel\'s Experiments', 'DNA', 'Acquired vs Inherited Traits', 'Evolution']),
          Chapter(id: 'ssc10s2_5', title: 'Towards Green Energy', description: 'Energy resources.', topics: ['Conventional Sources', 'Solar Energy', 'Wind Energy', 'Biofuels', 'Global Warming']),
          Chapter(id: 'ssc10s2_6', title: 'Animal Classification', description: 'Kingdom Animalia.', topics: ['Basis of Classification', 'Invertebrates', 'Vertebrates', 'Adaptations']),
          Chapter(id: 'ssc10s2_7', title: 'Introduction to Microbiology', description: 'Bacteria, fungi and viruses.', topics: ['Bacteria', 'Viruses', 'Fungi', 'Useful Microbes', 'Disease-causing Microbes']),
          Chapter(id: 'ssc10s2_8', title: 'Cell Biology and Biotechnology', description: 'DNA and genetic engineering basics.', topics: ['Cell Division', 'DNA Structure', 'Gene & Genome', 'Biotechnology Applications']),
          Chapter(id: 'ssc10s2_9', title: 'Social Health', description: 'Community health and diseases.', topics: ['Communicable Diseases', 'Non-communicable Diseases', 'Personal Hygiene', 'Mental Health']),
          Chapter(id: 'ssc10s2_10', title: 'Disaster Management', description: 'Natural and man-made disasters.', topics: ['Floods', 'Earthquakes', 'Cyclones', 'Industrial Disasters', 'Management Plans']),
        ],
      ),
      Subject(
        id: 'ssc10_eng',
        name: 'English',
        emoji: '📖',
        chapters: [
          Chapter(id: 'ssc10e1', title: 'Prose 1 – As I Grew Older', description: 'Langston Hughes poem and comprehension.', topics: ['Summary', 'Poetic Devices', 'Important Questions']),
          Chapter(id: 'ssc10e2', title: 'Writing Skills', description: 'Formal writing.', topics: ['Formal Letter', 'Notice', 'Report Writing', 'Email']),
          Chapter(id: 'ssc10e3', title: 'Grammar', description: 'Comprehensive grammar revision.', topics: ['Tenses', 'Voice', 'Narration', 'Prepositions', 'Conjunctions']),
        ],
      ),
      Subject(
        id: 'ssc10_hist',
        name: 'History',
        emoji: '🏛️',
        chapters: [
          Chapter(id: 'ssc10h1', title: 'Historiography: Development in the West', description: 'Modern historical thinking.', topics: ['Greek Historiography', 'Roman Historiography', 'Modern Historiography']),
          Chapter(id: 'ssc10h2', title: 'Historiography: Indian Tradition', description: 'Indian historical writing.', topics: ['Ancient Tradition', 'Medieval Tradition', 'Colonial & Post-Colonial']),
          Chapter(id: 'ssc10h3', title: 'Mass Media and History', description: 'Role of media in history.', topics: ['Print Media', 'Electronic Media', 'Social Media & History']),
          Chapter(id: 'ssc10h4', title: 'History of Arts in the World', description: 'Global art history.', topics: ['Cave Art', 'Egyptian Art', 'Greek & Roman Art', 'Renaissance Art', 'Modern Art']),
          Chapter(id: 'ssc10h5', title: 'India – Developments in Education', description: 'Education in colonial and modern India.', topics: ['Ancient Education', 'Colonial Education System', 'Post-Independence Reforms']),
          Chapter(id: 'ssc10h6', title: 'Entertainment and Sports', description: 'Historical development of sports.', topics: ['Olympic History', 'Indian Sports', 'Entertainment Industry']),
        ],
      ),
      Subject(
        id: 'ssc10_geo',
        name: 'Geography',
        emoji: '🌍',
        chapters: [
          Chapter(id: 'ssc10g1', title: 'Field Visit', description: 'Practical geography fieldwork.', topics: ['Objectives', 'Methodology', 'Data Collection', 'Presentation']),
          Chapter(id: 'ssc10g2', title: 'Location and Extent of India', description: 'India\'s geographical position.', topics: ['Latitude & Longitude', 'Land & Sea Boundaries', 'Neighbouring Countries']),
          Chapter(id: 'ssc10g3', title: 'Physiography of India', description: 'Major landforms.', topics: ['Himalayan Region', 'Northern Plains', 'Deccan Plateau', 'Coastal Plains', 'Islands']),
          Chapter(id: 'ssc10g4', title: 'Climate', description: 'Monsoon and seasons.', topics: ['Factors Affecting Climate', 'Seasons', 'Monsoon', 'Climatic Regions']),
          Chapter(id: 'ssc10g5', title: 'Natural Vegetation', description: 'Forests and biomes.', topics: ['Tropical Evergreen', 'Tropical Deciduous', 'Thorn Forests', 'Mangroves', 'Conservation']),
          Chapter(id: 'ssc10g6', title: 'Water Resources', description: 'River systems and irrigation.', topics: ['River Systems', 'Irrigation', 'Water Conservation', 'Multipurpose Projects']),
          Chapter(id: 'ssc10g7', title: 'Population', description: 'Demographics of India.', topics: ['Size & Distribution', 'Growth Rate', 'Density', 'Literacy', 'Occupational Structure']),
        ],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════
    // HSC Class 11
    // ══════════════════════════════════════════════════════════════════
    'HSC|Class 11': [
      Subject(
        id: 'hsc11_maths',
        name: 'Maths',
        emoji: '🔢',
        chapters: [
          Chapter(id: 'hsc11m1', title: 'Sets, Relations and Functions', description: 'Foundation of higher maths.', topics: ['Types of Sets', 'Venn Diagrams', 'Relations', 'Types of Functions']),
          Chapter(id: 'hsc11m2', title: 'Complex Numbers', description: 'Imaginary unit and Argand plane.', topics: ['Algebra of Complex Numbers', 'Modulus & Argument', 'Polar Form']),
          Chapter(id: 'hsc11m3', title: 'Sequences and Series', description: 'AP, GP and special series.', topics: ['Arithmetic Progression', 'Geometric Progression', 'Harmonic Progression', 'Special Series']),
          Chapter(id: 'hsc11m4', title: 'Permutations and Combinations', description: 'Counting principles.', topics: ['Fundamental Counting Principle', 'Permutations', 'Combinations', 'Applications']),
          Chapter(id: 'hsc11m5', title: 'Binomial Theorem', description: 'Expansion and applications.', topics: ['Binomial Expansion', 'General Term', 'Middle Term', 'Applications']),
          Chapter(id: 'hsc11m6', title: 'Limits and Continuity', description: 'Introduction to calculus.', topics: ['Concept of Limit', 'Algebra of Limits', 'Continuity', 'Discontinuity']),
          Chapter(id: 'hsc11m7', title: 'Differentiation', description: 'Derivatives and rules.', topics: ['First Principle', 'Differentiation Rules', 'Derivative of Trigonometric Functions', 'Chain Rule']),
          Chapter(id: 'hsc11m8', title: 'Integration', description: 'Anti-derivatives.', topics: ['Standard Formulae', 'Methods of Integration', 'Definite Integral']),
          Chapter(id: 'hsc11m9', title: 'Statistics', description: 'Measures of dispersion.', topics: ['Range', 'Mean Deviation', 'Variance', 'Standard Deviation']),
          Chapter(id: 'hsc11m10', title: 'Probability', description: 'Classical and axiomatic.', topics: ['Sample Space', 'Events', 'Addition Theorem', 'Conditional Probability']),
        ],
      ),
      Subject(
        id: 'hsc11_phy',
        name: 'Physics',
        emoji: '⚡',
        chapters: [
          Chapter(id: 'hsc11p1', title: 'Measurements', description: 'Units and dimensional analysis.', topics: ['SI Units', 'Dimensional Analysis', 'Errors in Measurement', 'Significant Figures']),
          Chapter(id: 'hsc11p2', title: 'Scalars and Vectors', description: 'Vector algebra.', topics: ['Scalar vs Vector', 'Vector Addition', 'Dot Product', 'Cross Product']),
          Chapter(id: 'hsc11p3', title: 'Motion in a Plane', description: 'Projectile motion.', topics: ['Projectile Motion', 'Circular Motion', 'Relative Velocity']),
          Chapter(id: 'hsc11p4', title: 'Laws of Motion', description: 'Newton\'s laws and friction.', topics: ['Newton\'s 3 Laws', 'Momentum', 'Friction', 'Circular Motion in a Vertical Plane']),
          Chapter(id: 'hsc11p5', title: 'Gravitation', description: 'Orbital motion and satellites.', topics: ['Kepler\'s Laws', 'Gravitational PE', 'Satellites', 'Escape Velocity']),
          Chapter(id: 'hsc11p6', title: 'Mechanical Properties of Solids & Fluids', description: 'Elasticity, viscosity, surface tension.', topics: ['Stress–Strain', 'Elastic Moduli', 'Viscosity', 'Surface Tension', 'Bernoulli\'s Theorem']),
          Chapter(id: 'hsc11p7', title: 'Thermal Properties of Matter', description: 'Heat, temperature and thermal expansion.', topics: ['Temperature Scales', 'Thermal Expansion', 'Calorimetry', 'Change of State']),
          Chapter(id: 'hsc11p8', title: 'Thermodynamics', description: 'Laws of thermodynamics.', topics: ['First Law', 'Second Law', 'Heat Engines', 'Entropy']),
          Chapter(id: 'hsc11p9', title: 'Oscillations', description: 'SHM and wave motion.', topics: ['Simple Harmonic Motion', 'Energy in SHM', 'Resonance']),
          Chapter(id: 'hsc11p10', title: 'Waves', description: 'Transverse and longitudinal waves.', topics: ['Wave Equation', 'Superposition', 'Stationary Waves', 'Doppler Effect']),
        ],
      ),
      Subject(
        id: 'hsc11_chem',
        name: 'Chemistry',
        emoji: '🧬',
        chapters: [
          Chapter(id: 'hsc11c1', title: 'Some Basic Concepts of Chemistry', description: 'Mole concept and stoichiometry.', topics: ['Laws of Chemical Combination', 'Mole Concept', 'Stoichiometry']),
          Chapter(id: 'hsc11c2', title: 'Structure of Atom', description: 'Quantum mechanical model.', topics: ['Bohr Model', 'Quantum Numbers', 'Orbitals', 'Electronic Configuration']),
          Chapter(id: 'hsc11c3', title: 'Classification of Elements', description: 'Periodic table trends.', topics: ['Periodic Law', 'Atomic Radius', 'Ionisation Enthalpy', 'Electronegativity']),
          Chapter(id: 'hsc11c4', title: 'Chemical Bonding and Molecular Structure', description: 'Types of bonds.', topics: ['Ionic Bond', 'Covalent Bond', 'VSEPR Theory', 'Hybridisation', 'Hydrogen Bond']),
          Chapter(id: 'hsc11c5', title: 'States of Matter', description: 'Gas laws and KMT.', topics: ['Gas Laws', 'Ideal Gas Equation', 'Kinetic Theory', 'Liquefaction']),
          Chapter(id: 'hsc11c6', title: 'Thermodynamics', description: 'Enthalpy and entropy.', topics: ['System & Surroundings', 'Enthalpy', 'Hess\'s Law', 'Entropy', 'Gibbs Energy']),
          Chapter(id: 'hsc11c7', title: 'Equilibrium', description: 'Chemical and ionic equilibrium.', topics: ['Le Chatelier\'s Principle', 'pH', 'Buffer Solutions', 'Solubility Product']),
          Chapter(id: 'hsc11c8', title: 'Redox Reactions', description: 'Oxidation-reduction.', topics: ['Oxidation State', 'Balancing Redox Equations', 'Electrochemical Series']),
          Chapter(id: 'hsc11c9', title: 'Hydrogen', description: 'Properties and uses.', topics: ['Preparation', 'Properties', 'Heavy Water', 'Hydrogen Peroxide']),
          Chapter(id: 'hsc11c10', title: 'Organic Chemistry Basics', description: 'Functional groups.', topics: ['Structural Isomerism', 'IUPAC Nomenclature', 'Functional Groups', 'Reaction Mechanisms']),
        ],
      ),
      Subject(
        id: 'hsc11_bio',
        name: 'Biology',
        emoji: '🌿',
        chapters: [
          Chapter(id: 'hsc11b1', title: 'The Living World', description: 'Diversity of life.', topics: ['Characteristics of Life', 'Taxonomy', 'Classification', 'Nomenclature']),
          Chapter(id: 'hsc11b2', title: 'Biological Classification', description: 'Five-kingdom classification.', topics: ['Monera', 'Protista', 'Fungi', 'Plantae', 'Animalia']),
          Chapter(id: 'hsc11b3', title: 'Plant Kingdom', description: 'Divisions of plants.', topics: ['Algae', 'Bryophyta', 'Pteridophyta', 'Gymnosperms', 'Angiosperms']),
          Chapter(id: 'hsc11b4', title: 'Animal Kingdom', description: 'Classification of animals.', topics: ['Porifera to Chordata', 'Key Features', 'Adaptive Characters']),
          Chapter(id: 'hsc11b5', title: 'Morphology of Flowering Plants', description: 'Structural organisation.', topics: ['Root', 'Stem', 'Leaf', 'Flower', 'Fruit & Seed']),
          Chapter(id: 'hsc11b6', title: 'Cell: The Unit of Life', description: 'Prokaryotic vs eukaryotic cells.', topics: ['Cell Theory', 'Cell Wall', 'Plasma Membrane', 'Cell Organelles', 'Nucleus']),
          Chapter(id: 'hsc11b7', title: 'Transport in Plants', description: 'Water and mineral transport.', topics: ['Imbibition', 'Osmosis', 'Ascent of Sap', 'Translocation of Food']),
          Chapter(id: 'hsc11b8', title: 'Mineral Nutrition', description: 'Essential mineral elements.', topics: ['Macro & Micro Nutrients', 'Deficiency Symptoms', 'Nitrogen Fixation']),
          Chapter(id: 'hsc11b9', title: 'Photosynthesis in Higher Plants', description: 'Light and dark reactions.', topics: ['Light Reactions', 'Calvin Cycle', 'C4 Pathway', 'CAM', 'Photorespiration']),
          Chapter(id: 'hsc11b10', title: 'Neural Control and Coordination', description: 'Nervous system.', topics: ['Neuron Structure', 'Resting & Action Potential', 'Synapse', 'CNS', 'Sense Organs']),
        ],
      ),
    ],

    // ══════════════════════════════════════════════════════════════════
    // ICSE Class 10
    // ══════════════════════════════════════════════════════════════════
    'ICSE|Class 10': [
      Subject(
        id: 'icse10_maths',
        name: 'Maths',
        emoji: '🔢',
        chapters: [
          Chapter(id: 'ic10m1', title: 'Commercial Mathematics', description: 'Banking and GST.', topics: ['Banking', 'Shares & Dividends', 'GST']),
          Chapter(id: 'ic10m2', title: 'Algebra', description: 'Linear inequations and polynomials.', topics: ['Linear Inequations', 'Quadratic Equations', 'Ratio & Proportion', 'Matrices']),
          Chapter(id: 'ic10m3', title: 'Coordinate Geometry', description: 'Straight line equations.', topics: ['Reflection', 'Distance Formula', 'Section Formula', 'Equation of Line']),
          Chapter(id: 'ic10m4', title: 'Geometry', description: 'Circles, constructions and similarity.', topics: ['Similarity', 'Loci', 'Circles', 'Tangents', 'Constructions']),
          Chapter(id: 'ic10m5', title: 'Trigonometry', description: 'Identities and heights.', topics: ['Trigonometric Identities', 'Heights & Distances']),
          Chapter(id: 'ic10m6', title: 'Statistics & Probability', description: 'Ogive and probability.', topics: ['Measures of Central Tendency', 'Ogive', 'Probability']),
          Chapter(id: 'ic10m7', title: 'Mensuration', description: 'Areas and volumes.', topics: ['Cylinder', 'Cone', 'Sphere', 'Combination of Solids']),
        ],
      ),
      Subject(
        id: 'icse10_phy',
        name: 'Physics',
        emoji: '⚡',
        chapters: [
          Chapter(id: 'ic10p1', title: 'Force, Work, Power and Energy', description: 'Mechanics.', topics: ['Turning Effect', 'Uniform Circular Motion', 'Machines', 'Energy Sources']),
          Chapter(id: 'ic10p2', title: 'Light', description: 'Refraction and optical instruments.', topics: ['Refraction', 'Lenses', 'Spectroscopy', 'Optical Instruments']),
          Chapter(id: 'ic10p3', title: 'Sound', description: 'Vibrations and waves.', topics: ['Vibrations', 'Properties of Sound', 'Ultrasound']),
          Chapter(id: 'ic10p4', title: 'Electricity', description: 'Current, resistance and power.', topics: ['Ohm\'s Law', 'Circuits', 'Power & Energy']),
          Chapter(id: 'ic10p5', title: 'Electromagnetism', description: 'Electromagnetic induction.', topics: ['Faraday\'s Laws', 'Motor', 'Generator', 'Transformers']),
          Chapter(id: 'ic10p6', title: 'Modern Physics', description: 'Nuclear physics.', topics: ['Radioactivity', 'Nuclear Reactions', 'Fission & Fusion', 'Safety']),
        ],
      ),
      Subject(
        id: 'icse10_chem',
        name: 'Chemistry',
        emoji: '🧬',
        chapters: [
          Chapter(id: 'ic10c1', title: 'Periodic Table', description: 'Trends in the modern periodic table.', topics: ['Periodic Law', 'Groups & Periods', 'Trends']),
          Chapter(id: 'ic10c2', title: 'Chemical Bonding', description: 'Ionic, covalent and coordinate bonding.', topics: ['Electrovalent Bond', 'Covalent Bond', 'Co-ordinate Bond']),
          Chapter(id: 'ic10c3', title: 'Acids, Bases and Salts', description: 'Reactions and indicators.', topics: ['Properties', 'Indicators', 'pH', 'Types of Salts']),
          Chapter(id: 'ic10c4', title: 'Analytical Chemistry', description: 'Salt analysis.', topics: ['Dry Tests', 'Wet Tests', 'Identification of Ions']),
          Chapter(id: 'ic10c5', title: 'Mole Concept and Stoichiometry', description: 'Calculations.', topics: ['Mole Definition', 'Avogadro\'s Number', 'Stoichiometric Calculations']),
          Chapter(id: 'ic10c6', title: 'Electrolysis', description: 'Faraday\'s laws.', topics: ['Electrolytic Cells', 'Faraday\'s Laws', 'Electroplating', 'Electrolysis of Solutions']),
          Chapter(id: 'ic10c7', title: 'Metallurgy', description: 'Extraction of metals.', topics: ['Ore', 'Concentration', 'Reduction', 'Refining']),
          Chapter(id: 'ic10c8', title: 'Organic Chemistry', description: 'Carbon compounds.', topics: ['Homologous Series', 'Functional Groups', 'Alkanes', 'Alkenes', 'Alcohols']),
        ],
      ),
      Subject(
        id: 'icse10_bio',
        name: 'Biology',
        emoji: '🌿',
        chapters: [
          Chapter(id: 'ic10b1', title: 'Cell Cycle, Cell Division', description: 'Mitosis and meiosis.', topics: ['Cell Cycle', 'Mitosis Stages', 'Meiosis Stages', 'Significance']),
          Chapter(id: 'ic10b2', title: 'Genetics', description: 'Mendel\'s laws and heredity.', topics: ['Mendel\'s Experiments', 'Laws of Inheritance', 'Sex Determination', 'Mutations']),
          Chapter(id: 'ic10b3', title: 'Absorption by Roots', description: 'Water & mineral absorption.', topics: ['Osmosis', 'Diffusion', 'Active Transport', 'Mineral Absorption']),
          Chapter(id: 'ic10b4', title: 'Transpiration', description: 'Loss of water from plants.', topics: ['Types of Transpiration', 'Factors Affecting', 'Significance', 'Guttation']),
          Chapter(id: 'ic10b5', title: 'Photosynthesis', description: 'Process and factors.', topics: ['Mechanism', 'Factors Affecting', 'Experiments', 'Significance']),
          Chapter(id: 'ic10b6', title: 'The Circulatory System', description: 'Human heart and blood vessels.', topics: ['Heart Structure', 'Cardiac Cycle', 'Blood Vessels', 'Blood Groups', 'Lymph']),
          Chapter(id: 'ic10b7', title: 'The Excretory System', description: 'Kidney structure and function.', topics: ['Kidney Structure', 'Urine Formation', 'Osmoregulation', 'Skin as Excretory Organ']),
          Chapter(id: 'ic10b8', title: 'The Nervous System', description: 'Brain and reflex.', topics: ['Neuron', 'CNS', 'PNS', 'Reflex Action', 'Sense Organs']),
        ],
      ),
      Subject(
        id: 'icse10_eng',
        name: 'English',
        emoji: '📖',
        chapters: [
          Chapter(id: 'ic10e1', title: 'Prose Comprehension', description: 'Unseen passages.', topics: ['Vocabulary', 'Inference Questions', 'Summary Writing']),
          Chapter(id: 'ic10e2', title: 'Literature', description: 'Prescribed texts.', topics: ['Short Stories', 'Poetry Analysis', 'Drama']),
          Chapter(id: 'ic10e3', title: 'Writing Skills', description: 'Composition formats.', topics: ['Essay', 'Letter', 'Email', 'Debate', 'Notice']),
          Chapter(id: 'ic10e4', title: 'Grammar', description: 'Advanced grammar.', topics: ['Reported Speech', 'Transformations', 'Phrasal Verbs', 'Error Correction']),
        ],
      ),
    ],
  };

  // ── Subject builders for fallback ─────────────────────────────────────────
  static Subject _maths(int classNum) => Subject(
        id: 'maths_$classNum',
        name: 'Maths',
        emoji: '🔢',
        chapters: [
          Chapter(id: 'm${classNum}_1', title: 'Number System', description: 'Numbers and operations.', topics: ['Natural Numbers', 'Integers', 'Rational Numbers']),
          Chapter(id: 'm${classNum}_2', title: 'Algebra', description: 'Expressions and equations.', topics: ['Variables', 'Linear Equations', 'Inequalities']),
          Chapter(id: 'm${classNum}_3', title: 'Geometry', description: 'Shapes and properties.', topics: ['Lines & Angles', 'Triangles', 'Quadrilaterals', 'Circles']),
          Chapter(id: 'm${classNum}_4', title: 'Statistics', description: 'Data handling.', topics: ['Data Collection', 'Graphs', 'Mean, Median, Mode']),
        ],
      );

  static Subject _science(int classNum) => Subject(
        id: 'science_$classNum',
        name: 'Science',
        emoji: '🧪',
        chapters: [
          Chapter(id: 's${classNum}_1', title: 'Physics', description: 'Motion and forces.', topics: ['Motion', 'Force', 'Energy', 'Light', 'Sound']),
          Chapter(id: 's${classNum}_2', title: 'Chemistry', description: 'Matter and reactions.', topics: ['Matter', 'Atoms', 'Molecules', 'Chemical Reactions']),
          Chapter(id: 's${classNum}_3', title: 'Biology', description: 'Living world.', topics: ['Cells', 'Plants', 'Animals', 'Ecology']),
        ],
      );

  static Subject _english(int classNum) => Subject(
        id: 'english_$classNum',
        name: 'English',
        emoji: '📖',
        chapters: [
          Chapter(id: 'e${classNum}_1', title: 'Reading Comprehension', description: 'Passages and inference.', topics: ['Vocabulary', 'Main Idea', 'Inference']),
          Chapter(id: 'e${classNum}_2', title: 'Writing Skills', description: 'Essays and letters.', topics: ['Essay Writing', 'Letter Writing', 'Formal Communication']),
          Chapter(id: 'e${classNum}_3', title: 'Grammar', description: 'Core grammar rules.', topics: ['Tenses', 'Articles', 'Prepositions', 'Sentence Structures']),
        ],
      );

  static Subject _evs(int classNum) => Subject(
        id: 'evs_$classNum',
        name: 'EVS',
        emoji: '🌍',
        chapters: [
          Chapter(id: 'ev${classNum}_1', title: 'Our Environment', description: 'Natural environment.', topics: ['Components of Environment', 'Biotic & Abiotic', 'Food Chain']),
          Chapter(id: 'ev${classNum}_2', title: 'Natural Resources', description: 'Conservation.', topics: ['Types of Resources', 'Conservation Methods', 'Sustainable Development']),
        ],
      );

  static Subject _socialScience(int classNum) => Subject(
        id: 'sst_$classNum',
        name: 'Social Science',
        emoji: '🏛️',
        chapters: [
          Chapter(id: 'ss${classNum}_1', title: 'History', description: 'Past events.', topics: ['Ancient History', 'Medieval History', 'Modern History']),
          Chapter(id: 'ss${classNum}_2', title: 'Geography', description: 'Physical world.', topics: ['Maps', 'Landforms', 'Climate', 'Resources']),
          Chapter(id: 'ss${classNum}_3', title: 'Civics', description: 'Government and democracy.', topics: ['Constitution', 'Rights & Duties', 'Government Structures']),
        ],
      );

  static Subject _hindi(int classNum) => Subject(
        id: 'hindi_$classNum',
        name: 'Hindi',
        emoji: '🔤',
        chapters: [
          Chapter(id: 'h${classNum}_1', title: 'गद्य – Prose', description: 'हिंदी गद्य पाठ.', topics: ['पाठ 1', 'पाठ 2', 'पाठ 3', 'महत्वपूर्ण प्रश्न']),
          Chapter(id: 'h${classNum}_2', title: 'पद्य – Poetry', description: 'हिंदी काव्य.', topics: ['कविता 1', 'कविता 2', 'काव्य-सौंदर्य', 'व्याख्या']),
          Chapter(id: 'h${classNum}_3', title: 'व्याकरण – Grammar', description: 'हिंदी व्याकरण.', topics: ['संज्ञा', 'सर्वनाम', 'क्रिया', 'समास', 'अलंकार']),
          Chapter(id: 'h${classNum}_4', title: 'लेखन – Writing', description: 'रचनात्मक लेखन.', topics: ['पत्र लेखन', 'निबंध', 'अनुच्छेद लेखन']),
        ],
      );

  static Subject _computer(int classNum) => Subject(
        id: 'computer_$classNum',
        name: 'Computer',
        emoji: '💻',
        chapters: [
          Chapter(id: 'comp${classNum}_1', title: 'Programming Basics', description: 'Introduction to coding.', topics: ['Variables', 'Conditions', 'Loops', 'Functions']),
          Chapter(id: 'comp${classNum}_2', title: 'Data Structures', description: 'Arrays and lists.', topics: ['Arrays', 'Strings', 'Lists', 'Dictionaries']),
          Chapter(id: 'comp${classNum}_3', title: 'Networking', description: 'Internet basics.', topics: ['LAN/WAN', 'Protocols', 'IP Address', 'Cyber Security']),
        ],
      );
}