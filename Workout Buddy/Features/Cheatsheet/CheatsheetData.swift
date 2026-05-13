import SwiftUI

// MARK: – Lightweight model structs (no Firestore, pure static reference data)

struct CSSWeekDay:       Identifiable { let id = UUID(); let day, session, focus, duration, intensity, postureWork: String }
struct CSSMobilityEx:    Identifiable { let id = UUID(); let name, setsReps, duration, targets, howTo: String }
struct CSSPullUpWeek:    Identifiable { let id = UUID(); let period, sets, repsPerSet, rest, totalReps, notes: String }
struct CSSPullUpVariant: Identifiable { let id = UUID(); let name, grip, primaryMuscle, difficulty, whenToAdd: String }
struct CSSFoodRow:       Identifiable { let id = UUID(); let name, portion, stat1, stat2, notes: String }
struct CSSFruitRow:      Identifiable { let id = UUID(); let name, carbs, fiber, benefit, timing: String }
struct CSSVeggieRow:     Identifiable { let id = UUID(); let name, fiber, benefit, notes: String }
struct CSSSuppRow:       Identifiable {
    let id = UUID(); let name, dose, timing, why, priority: String
    var priorityColor: Color {
        switch priority {
        case "ESSENTIAL": return AppTheme.accentGreen
        case "USEFUL":    return AppTheme.accentBlue
        case "OPTIONAL":  return AppTheme.accentOrange
        default:          return AppTheme.textMuted
        }
    }
}
struct CSSAvoidRow: Identifiable {
    let id = UUID(); let name, reason, severity, alternative: String
    var severityColor: Color {
        switch severity {
        case "AVOID", "AVOID DAILY", "NEVER": return AppTheme.accent
        case "MINIMIZE":                       return AppTheme.accentOrange
        default:                               return AppTheme.accentBlue
        }
    }
}
struct CSSMealRow: Identifiable { let id = UUID(); let time, label, food, portions, protein, carbs, fat: String }
struct CSSDayPlan: Identifiable {
    let id = UUID(); let day, subtitle: String; let color: Color
    let meals: [CSSMealRow]; let totalP, totalC, totalF, totalCal: String
}
struct CSSRule:       Identifiable { let id = UUID(); let number: Int; let rule, why: String }
struct CSSTimingRow:  Identifiable { let id = UUID(); let phase, timing, eat, avoid, why: String }

// MARK: – Static data from PDF plans

enum CheatsheetData {

    // MARK: Weekly schedule
    static let weeklySchedule: [CSSWeekDay] = [
        .init(day:"MON", session:"Upper Body Gym",     focus:"Push + Pull + Core",   duration:"60-75 min",  intensity:"High",     postureWork:"Dead bug, planks"),
        .init(day:"TUE", session:"Run 8-10 km",        focus:"Zone 2 Aerobic Base",  duration:"60-75 min",  intensity:"Moderate", postureWork:"Running form drills"),
        .init(day:"WED", session:"Lower Body Gym",     focus:"Glutes + Legs + Core", duration:"60-75 min",  intensity:"High",     postureWork:"Hip flexor focus"),
        .init(day:"THU", session:"Swim",               focus:"Active Recovery",       duration:"40-50 min",  intensity:"Low",      postureWork:"Mobility after swim"),
        .init(day:"FRI", session:"Full Body + Pull-ups",focus:"Strength + Power",    duration:"60-75 min",  intensity:"High",     postureWork:"Thoracic mobility"),
        .init(day:"SAT", session:"Long Run 12-18 km",  focus:"Endurance Build",      duration:"90-120 min", intensity:"Moderate", postureWork:"Post-run stretching"),
        .init(day:"SUN", session:"Full Rest",          focus:"Recovery",             duration:"—",          intensity:"Zero",     postureWork:"15 min foam roll"),
    ]

    // MARK: Training principles
    static let principles: [(title: String, rule: String, why: String)] = [
        ("Progressive Overload",  "Add weight/reps/distance every week — even 1%",             "Muscles only grow when challenged beyond current capacity"),
        ("Zone 2 Running",        "Keep HR 135-145 BPM — can hold full conversation",          "Builds aerobic base without burning muscle mass"),
        ("Compound First",        "Start sessions with big movements (squat, deadlift, bench)", "Most energy + focus when fresh = best strength gains"),
        ("Rest = Growth",         "48hr between same muscle group — muscles grow at REST",      "Training breaks muscle down. Sleep + food build it back bigger"),
        ("Posture Priority",      "Every session includes glute + core activation first",       "Desk job constantly damages posture — training must counteract it"),
        ("Pull Up King",          "Pull ups every single training day — Arda's foundation",     "Best upper body compound — back, biceps, core, grip all at once"),
        ("Consistency Wins",      "80% consistent for 12 months beats perfect for 4",          "Fitness is cumulative — missing days costs more than bad sessions"),
    ]

    // MARK: Morning mobility (15 min daily)
    static let morningMobility: [CSSMobilityEx] = [
        .init(name:"Cat-Cow",                setsReps:"2×15 reps",       duration:"2 min", targets:"Spine, lower back, core",      howTo:"On hands & knees. Arch back up (cat), drop belly down (cow)."),
        .init(name:"Hip Flexor Stretch",      setsReps:"60 sec / side",  duration:"2 min", targets:"Hip flexors, pelvic tilt fix", howTo:"Kneel on one knee. Push hips forward. Feel stretch in front hip."),
        .init(name:"Glute Bridge",            setsReps:"3×20 reps",      duration:"3 min", targets:"Glutes, hamstrings, lower back",howTo:"Lie on back, knees bent. Drive hips up, squeeze glutes at top."),
        .init(name:"Dead Bug",                setsReps:"3×10 each side", duration:"3 min", targets:"Deep core, spine stability",   howTo:"Arms up, knees at 90°. Lower opposite arm + leg slowly."),
        .init(name:"Thoracic Rotation",       setsReps:"2×15 each side", duration:"2 min", targets:"Upper back, shoulder mobility",howTo:"Sit cross-legged. Hand behind head. Rotate upper body."),
        .init(name:"Hamstring Stretch",       setsReps:"60 sec / side",  duration:"2 min", targets:"Hamstrings, posterior chain",  howTo:"Lie on back. Lift one leg, hold behind thigh. Pull gently."),
        .init(name:"World's Greatest Stretch",setsReps:"5 reps / side",  duration:"1 min", targets:"Full body, hip + thoracic",   howTo:"Lunge forward, same-side hand down, rotate opposite arm to sky."),
    ]

    // MARK: Pull-up progression
    static let pullUpProgression: [CSSPullUpWeek] = [
        .init(period:"Week 1-2",  sets:"5",  repsPerSet:"Max (3-5)",  rest:"2 min",  totalReps:"15-25",   notes:"Find your baseline. Use assistance band if needed."),
        .init(period:"Week 3-4",  sets:"5",  repsPerSet:"Add 1 rep",  rest:"2 min",  totalReps:"20-30",   notes:"Slow negatives — 3 sec down. Build tendon strength."),
        .init(period:"Week 5-6",  sets:"5",  repsPerSet:"Add 1 rep",  rest:"90 sec", totalReps:"25-35",   notes:"Start varying grip — wide, narrow, neutral."),
        .init(period:"Week 7-8",  sets:"6",  repsPerSet:"Add 1 rep",  rest:"90 sec", totalReps:"35-50",   notes:"Add weighted vest 5 kg if getting easy."),
        .init(period:"Month 3",   sets:"6",  repsPerSet:"10+ reps",   rest:"90 sec", totalReps:"60+",     notes:"Milestone: 10 clean reps = strong foundation."),
        .init(period:"Month 4-5", sets:"5",  repsPerSet:"12-15 reps", rest:"2 min",  totalReps:"70-80",   notes:"Add: archer pull-ups, typewriters for variety."),
        .init(period:"Month 6",   sets:"5",  repsPerSet:"15-20 reps", rest:"2 min",  totalReps:"80-100",  notes:"Milestone: 20 reps = serious hybrid athlete level."),
        .init(period:"Month 9-12",sets:"10", repsPerSet:"20-30 reps", rest:"Varied", totalReps:"200-300", notes:"Arda territory. Add towel pulls, one-arm progressions."),
    ]

    static let pullUpVariants: [CSSPullUpVariant] = [
        .init(name:"Standard Pull Up", grip:"Overhand shoulder-width",  primaryMuscle:"Lats, upper back",          difficulty:"Medium",    whenToAdd:"From day 1"),
        .init(name:"Chin Up",          grip:"Underhand shoulder-width", primaryMuscle:"Biceps + lats",             difficulty:"Easier",    whenToAdd:"From day 1 — easier starter"),
        .init(name:"Wide Grip",        grip:"Overhand wide",            primaryMuscle:"Outer lats, V-taper shape", difficulty:"Hard",      whenToAdd:"Month 2+"),
        .init(name:"Neutral Grip",     grip:"Palms facing each other",  primaryMuscle:"Lats + biceps, wrist safe", difficulty:"Medium",    whenToAdd:"Month 1 — good for wrists"),
        .init(name:"Slow Negative",    grip:"Any grip",                 primaryMuscle:"Full eccentric damage",     difficulty:"Hard",      whenToAdd:"From day 1 — 5 sec down"),
        .init(name:"L-Sit Pull Up",    grip:"Any grip",                 primaryMuscle:"Core + lats, full body",    difficulty:"Very Hard", whenToAdd:"Month 4+"),
        .init(name:"Weighted Pull Up", grip:"Standard + belt or vest",  primaryMuscle:"Maximum strength overload", difficulty:"Advanced",  whenToAdd:"Month 3+ when 10+ reps easy"),
    ]

    // MARK: Food guide — Proteins
    static let proteins: [CSSFoodRow] = [
        .init(name:"Chicken breast", portion:"150g",       stat1:"45g protein", stat2:"4g fat",  notes:"Best lean protein — eat daily"),
        .init(name:"Eggs (whole)",   portion:"3 eggs",     stat1:"18g protein", stat2:"15g fat", notes:"Complete amino acids — eat 3-4/day"),
        .init(name:"Egg whites",     portion:"5 whites",   stat1:"18g protein", stat2:"0g fat",  notes:"Pure protein, zero fat"),
        .init(name:"Salmon",         portion:"150g",       stat1:"35g protein", stat2:"20g fat", notes:"Best — omega 3 + protein combo"),
        .init(name:"Tuna (canned)",  portion:"150g",       stat1:"33g protein", stat2:"3g fat",  notes:"Budget king — 3×/week max"),
        .init(name:"Greek yogurt",   portion:"200g",       stat1:"20g protein", stat2:"4g fat",  notes:"Protein + probiotics — daily"),
        .init(name:"Cottage cheese", portion:"200g",       stat1:"24g protein", stat2:"5g fat",  notes:"Casein protein — great before bed"),
        .init(name:"Turkey breast",  portion:"150g",       stat1:"40g protein", stat2:"3g fat",  notes:"Leaner than chicken"),
        .init(name:"Beef (lean)",    portion:"150g",       stat1:"38g protein", stat2:"12g fat", notes:"Iron + zinc — 2-3×/week"),
        .init(name:"Shrimp",         portion:"150g",       stat1:"30g protein", stat2:"2g fat",  notes:"Low cal, high protein"),
        .init(name:"Whey protein",   portion:"1 scoop",    stat1:"25g protein", stat2:"2g fat",  notes:"Post-workout convenience"),
    ]

    // MARK: Carbs
    static let carbs: [CSSFoodRow] = [
        .init(name:"Oats (rolled)",     portion:"80g dry",      stat1:"54g carbs", stat2:"11g protein", notes:"Best breakfast — slow energy, great fiber"),
        .init(name:"White rice",        portion:"200g cooked",  stat1:"52g carbs", stat2:"4g protein",  notes:"Fast carb — perfect post-workout & race"),
        .init(name:"Brown rice",        portion:"200g cooked",  stat1:"46g carbs", stat2:"5g protein",  notes:"Slower than white — main meals"),
        .init(name:"Sweet potato",      portion:"200g",         stat1:"38g carbs", stat2:"3g protein",  notes:"Vitamins + carbs — excellent choice"),
        .init(name:"Regular potato",    portion:"200g boiled",  stat1:"30g carbs", stat2:"4g protein",  notes:"Cheap, effective carb source"),
        .init(name:"Whole grain bread", portion:"2 slices 80g", stat1:"38g carbs", stat2:"7g protein",  notes:"Convenient carb + fiber combo"),
        .init(name:"White bread",       portion:"2 slices 80g", stat1:"42g carbs", stat2:"6g protein",  notes:"Fast carb — use pre/post workout"),
        .init(name:"Whole grain pasta", portion:"200g cooked",  stat1:"48g carbs", stat2:"9g protein",  notes:"Best pre-training meal"),
        .init(name:"White pasta",       portion:"200g cooked",  stat1:"52g carbs", stat2:"8g protein",  notes:"Fast energy — race eve dinner"),
        .init(name:"Quinoa",            portion:"200g cooked",  stat1:"39g carbs", stat2:"9g protein",  notes:"Complete protein + carbs — excellent"),
        .init(name:"Banana",            portion:"1 large",      stat1:"31g carbs", stat2:"1g protein",  notes:"Best pre-workout fruit — fast energy"),
        .init(name:"Dates",             portion:"5 dates (45g)",stat1:"36g carbs", stat2:"1g protein",  notes:"Natural gel alternative during run"),
        .init(name:"Honey",             portion:"1 tbsp",       stat1:"17g carbs", stat2:"0g protein",  notes:"Quick energy — add to oats/tea"),
    ]

    // MARK: Healthy fats
    static let fats: [CSSFoodRow] = [
        .init(name:"Avocado",       portion:"½ medium",     stat1:"15g fat", stat2:"", notes:"Best fat source — omega 9, potassium"),
        .init(name:"Olive oil",     portion:"1 tbsp",       stat1:"14g fat", stat2:"", notes:"Cooking and salads — anti-inflammatory"),
        .init(name:"Mixed nuts",    portion:"30g handful",  stat1:"16g fat", stat2:"", notes:"Healthy fats + protein — snack"),
        .init(name:"Almonds",       portion:"30g (23 nuts)",stat1:"15g fat", stat2:"", notes:"Vitamin E + magnesium — recovery"),
        .init(name:"Walnuts",       portion:"30g",          stat1:"18g fat", stat2:"", notes:"Omega 3 — brain and joint health"),
        .init(name:"Peanut butter", portion:"2 tbsp",       stat1:"16g fat", stat2:"", notes:"Protein + fat — great pre-bed snack"),
        .init(name:"Chia seeds",    portion:"2 tbsp",       stat1:"9g fat",  stat2:"", notes:"Omega 3 + fiber — add to yogurt/oats"),
        .init(name:"Salmon",        portion:"150g",         stat1:"20g fat", stat2:"", notes:"Omega 3 king — eat 2-3×/week"),
        .init(name:"Eggs (yolk)",   portion:"3 yolks",      stat1:"15g fat", stat2:"", notes:"Vitamin D + choline — eat whole eggs"),
    ]

    // MARK: Fruits
    static let fruits: [CSSFruitRow] = [
        .init(name:"Banana",      carbs:"27g", fiber:"3g",   benefit:"Potassium + fast energy",               timing:"Pre-workout, during run"),
        .init(name:"Berries",     carbs:"12g", fiber:"4g",   benefit:"Antioxidants — best recovery fruit",    timing:"Morning, post-workout"),
        .init(name:"Strawberry",  carbs:"8g",  fiber:"2g",   benefit:"Vitamin C — immune + collagen",         timing:"Any time"),
        .init(name:"Kiwi",        carbs:"10g", fiber:"2g",   benefit:"Vitamin C + potassium — immune boost",  timing:"Morning, post-workout"),
        .init(name:"Orange",      carbs:"15g", fiber:"3g",   benefit:"Vitamin C + hydration",                 timing:"Morning, snack"),
        .init(name:"Apple",       carbs:"21g", fiber:"4g",   benefit:"Soluble fiber — gut health",            timing:"Snack, NOT pre-workout"),
        .init(name:"Mango",       carbs:"25g", fiber:"3g",   benefit:"Vitamin A + fast carbs",                timing:"Pre-workout snack"),
        .init(name:"Dates",       carbs:"36g", fiber:"3g",   benefit:"Natural gel — race fuel",               timing:"During long runs"),
        .init(name:"Pomegranate", carbs:"18g", fiber:"4g",   benefit:"Anti-inflammatory — recovery",          timing:"Post-workout, evening"),
        .init(name:"Beetroot",    carbs:"10g", fiber:"3g",   benefit:"Nitrates — oxygen delivery to muscles", timing:"Pre-race, pre-workout"),
        .init(name:"Watermelon",  carbs:"8g",  fiber:"0.5g", benefit:"Hydration + citrulline",                timing:"Post-workout, hot days"),
        .init(name:"Pineapple",   carbs:"20g", fiber:"2g",   benefit:"Bromelain — reduces inflammation",      timing:"Post-workout"),
    ]

    // MARK: Vegetables
    static let vegetables: [CSSVeggieRow] = [
        .init(name:"Spinach",      fiber:"2g/100g",   benefit:"Iron + magnesium — oxygen transport",     notes:"Add to everything"),
        .init(name:"Broccoli",     fiber:"3g/100g",   benefit:"Vitamin C + antioxidants",                notes:"Eat 4-5×/week"),
        .init(name:"Carrot",       fiber:"3g/100g",   benefit:"Beta-carotene + potassium",               notes:"Raw or cooked both fine"),
        .init(name:"Beetroot",     fiber:"3g/100g",   benefit:"Nitrates — performance booster",          notes:"Pre-training or race"),
        .init(name:"Kale",         fiber:"4g/100g",   benefit:"Vitamin K + calcium — bone health",       notes:"Smoothies or salad"),
        .init(name:"Bell peppers", fiber:"2g/100g",   benefit:"Highest vitamin C of any vegetable",      notes:"Raw snacking"),
        .init(name:"Sweet potato", fiber:"3g/100g",   benefit:"Vitamin A + complex carbs",               notes:"Counts as carb source"),
        .init(name:"Tomato",       fiber:"1g/100g",   benefit:"Lycopene — anti-inflammatory",            notes:"Daily, any form"),
        .init(name:"Cucumber",     fiber:"0.5g/100g", benefit:"Hydration + low cal",                    notes:"Snacking, salads"),
        .init(name:"Avocado",      fiber:"7g each",   benefit:"Healthy fat + fiber combo",               notes:"Counts as fat source"),
        .init(name:"Garlic",       fiber:"trace",     benefit:"Natural antibiotic — immune boost",       notes:"Daily cooking"),
        .init(name:"Ginger",       fiber:"trace",     benefit:"Anti-inflammatory — recovery aid",        notes:"Tea, cooking daily"),
    ]

    // MARK: Avoid
    static let avoidFoods: [CSSAvoidRow] = [
        .init(name:"Alcohol",                  reason:"Destroys muscle protein synthesis. Dehydrates, raises RHR, kills recovery", severity:"AVOID",       alternative:"Sparkling water + lime"),
        .init(name:"Processed meats",          reason:"High sodium, preservatives. Inflammation, no real protein",                  severity:"MINIMIZE",    alternative:"Chicken breast, turkey"),
        .init(name:"Sugary drinks (Coke etc)", reason:"Blood sugar spike + crash. Empty calories, no nutrients",                    severity:"AVOID DAILY", alternative:"Water, ayran, green tea"),
        .init(name:"Fast food daily",          reason:"Trans fats, excessive sodium. Low micronutrients",                           severity:"LIMIT",       alternative:"80% home cooked meals"),
        .init(name:"Deep fried food",          reason:"Trans fats — inflammation. Slow digestion, bad for joints",                  severity:"MINIMIZE",    alternative:"Grilled, baked, boiled"),
        .init(name:"White sugar (added)",      reason:"Empty calories. Insulin spikes, fat storage",                                severity:"MINIMIZE",    alternative:"Honey, dates, fruit"),
        .init(name:"Pastries / cakes",         reason:"Trans fats + sugar combo. Worst for body composition",                       severity:"OCCASIONAL",  alternative:"1-2×/week maximum"),
        .init(name:"Skipping meals",           reason:"Muscle breakdown (catabolism). Metabolism slows down",                       severity:"NEVER",       alternative:"Meal prep in advance"),
        .init(name:"Energy drinks",            reason:"Excessive caffeine + sugar. Heart rate stress",                              severity:"AVOID",       alternative:"Coffee, green tea"),
        .init(name:"Hookah / smoking",         reason:"Carbon monoxide reduces O2. Lung capacity drops, VO2max suffers",           severity:"AVOID",       alternative:"Nothing — just stop"),
    ]

    // MARK: 7-day meal plans
    static let mealPlans: [CSSDayPlan] = [
        CSSDayPlan(day:"Monday", subtitle:"Upper Body Gym • Training", color: AppTheme.accentBlue, meals: [
            .init(time:"7:00",  label:"Breakfast",    food:"Oatmeal + banana + eggs + honey, green tea",   portions:"Oats 80g · 1 banana · 3 eggs · 1 tbsp honey", protein:"25", carbs:"72", fat:"15"),
            .init(time:"10:00", label:"Snack",        food:"Greek yogurt + berries + almonds",              portions:"200g yogurt · 100g berries · 20g almonds",     protein:"22", carbs:"22", fat:"12"),
            .init(time:"13:00", label:"Lunch",        food:"Rice + chicken breast + vegetables, ayran",     portions:"200g rice · 150g chicken · mixed veg",         protein:"49", carbs:"56", fat:"5"),
            .init(time:"17:30", label:"Pre-workout",  food:"Banana + peanut butter, water + creatine 5g",  portions:"1 banana · 1 tbsp peanut butter",              protein:"4",  carbs:"35", fat:"8"),
            .init(time:"19:30", label:"Post-workout", food:"Protein shake + white rice (immediately)",      portions:"1 scoop protein · 150g rice cooked",           protein:"30", carbs:"40", fat:"3"),
            .init(time:"20:30", label:"Dinner",       food:"Salmon + sweet potato + salad, olive oil",     portions:"150g salmon · 200g sweet potato",              protein:"36", carbs:"40", fat:"22"),
        ], totalP:"~166g", totalC:"~265g", totalF:"~65g", totalCal:"~2800 kcal"),

        CSSDayPlan(day:"Tuesday", subtitle:"Run 8-10 km • Training", color: AppTheme.accentBlue, meals: [
            .init(time:"7:00",  label:"Breakfast", food:"Eggs + whole grain toast + avocado, coffee",  portions:"3 eggs · 2 slices toast · ½ avocado",  protein:"22", carbs:"38", fat:"22"),
            .init(time:"10:00", label:"Snack",     food:"Banana + Greek yogurt, water",                 portions:"1 banana · 150g yogurt",               protein:"13", carbs:"38", fat:"3"),
            .init(time:"13:00", label:"Lunch",     food:"Pasta + chicken + tomato sauce, salad",        portions:"200g pasta · 150g chicken",            protein:"49", carbs:"58", fat:"6"),
            .init(time:"17:30", label:"Pre-run",   food:"Banana + dates + water, small coffee optional",portions:"1 banana · 4-5 dates",                 protein:"2",  carbs:"55", fat:"0"),
            .init(time:"19:30", label:"Post-run",  food:"Protein shake + banana or chicken + rice",     portions:"1 scoop protein · 1 banana / 150g rice",protein:"27", carbs:"45", fat:"3"),
            .init(time:"20:30", label:"Dinner",    food:"Chicken + rice + vegetables, ayran 200ml",     portions:"150g chicken · 150g rice · veg",        protein:"49", carbs:"42", fat:"5"),
        ], totalP:"~162g", totalC:"~276g", totalF:"~39g", totalCal:"~2700 kcal"),

        CSSDayPlan(day:"Wednesday", subtitle:"Lower Body Gym • Training", color: AppTheme.accentPurple, meals: [
            .init(time:"7:00",  label:"Breakfast",    food:"Oatmeal + protein powder + berries, creatine 5g", portions:"Oats 80g · 1 scoop protein · 100g berries", protein:"35", carbs:"65", fat:"8"),
            .init(time:"10:00", label:"Snack",        food:"Cottage cheese + apple, green tea",               portions:"200g cottage cheese · 1 apple",            protein:"24", carbs:"27", fat:"5"),
            .init(time:"13:00", label:"Lunch",        food:"Sweet potato + beef + salad",                     portions:"200g sweet potato · 150g lean beef",       protein:"40", carbs:"42", fat:"14"),
            .init(time:"17:30", label:"Pre-workout",  food:"White rice + chicken, water + creatine",          portions:"100g rice cooked · 80g chicken",           protein:"27", carbs:"28", fat:"3"),
            .init(time:"19:30", label:"Post-workout", food:"Protein shake + banana + oats (or big meal)",     portions:"1 scoop · 1 banana · 40g oats",            protein:"30", carbs:"65", fat:"5"),
            .init(time:"20:30", label:"Dinner",       food:"Tuna + quinoa + vegetables, olive oil",           portions:"150g tuna · 150g quinoa · mixed veg",      protein:"45", carbs:"40", fat:"8"),
        ], totalP:"~201g", totalC:"~267g", totalF:"~43g", totalCal:"~2750 kcal"),

        CSSDayPlan(day:"Thursday", subtitle:"Swim • Active Recovery", color: AppTheme.accentGreen, meals: [
            .init(time:"7:00",      label:"Breakfast", food:"Eggs + avocado + whole grain bread, coffee",  portions:"3 eggs · ½ avocado · 2 slices bread",     protein:"22", carbs:"38", fat:"22"),
            .init(time:"10:00",     label:"Snack",     food:"Apple + almonds + green tea, water",           portions:"1 apple · 30g almonds",                   protein:"6",  carbs:"24", fat:"15"),
            .init(time:"13:00",     label:"Lunch",     food:"Chicken + salad + small rice, ayran",          portions:"150g chicken · salad · 100g rice cooked", protein:"45", carbs:"30", fat:"5"),
            .init(time:"16:00",     label:"Snack",     food:"Greek yogurt + berries + chia, water",         portions:"150g yogurt · 100g berries · 1 tbsp chia",protein:"16", carbs:"18", fat:"7"),
            .init(time:"19:30",     label:"Dinner",    food:"Salmon + vegetables + potato, olive oil",      portions:"150g salmon · mixed veg · 150g potato",   protein:"36", carbs:"28", fat:"22"),
            .init(time:"Before bed",label:"Optional",  food:"Cottage cheese or protein shake",               portions:"150g cottage cheese",                     protein:"18", carbs:"4",  fat:"4"),
        ], totalP:"~143g", totalC:"~142g", totalF:"~75g", totalCal:"~2200 kcal"),

        CSSDayPlan(day:"Friday", subtitle:"Full Body + Pull-ups • Training", color: AppTheme.accentOrange, meals: [
            .init(time:"7:00",  label:"Breakfast",    food:"Oatmeal + banana + eggs, coffee + creatine 5g", portions:"Oats 80g · 1 banana · 2 eggs",           protein:"22", carbs:"68", fat:"10"),
            .init(time:"10:00", label:"Snack",        food:"Protein shake + apple, water",                   portions:"1 scoop protein · 1 apple",              protein:"26", carbs:"30", fat:"3"),
            .init(time:"13:00", label:"Lunch",        food:"Rice + chicken + broccoli, ayran",               portions:"200g rice · 150g chicken · 200g broccoli",protein:"49", carbs:"58", fat:"5"),
            .init(time:"17:30", label:"Pre-workout",  food:"Dates + banana + water, pre-workout coffee",     portions:"5 dates · 1 banana",                     protein:"2",  carbs:"65", fat:"0"),
            .init(time:"19:30", label:"Post-workout", food:"Protein shake + rice cakes (or big dinner)",     portions:"1 scoop protein · 4 rice cakes",         protein:"27", carbs:"35", fat:"3"),
            .init(time:"20:30", label:"Dinner",       food:"Beef + sweet potato + salad, olive oil",         portions:"150g beef · 200g sweet potato",          protein:"38", carbs:"42", fat:"14"),
        ], totalP:"~164g", totalC:"~298g", totalF:"~35g", totalCal:"~2800 kcal"),

        CSSDayPlan(day:"Saturday", subtitle:"Long Run 12-18 km • Training", color: AppTheme.accent, meals: [
            .init(time:"7:00",    label:"Breakfast (2hr before)", food:"Oatmeal + banana + honey + bread, coffee + 500ml water",    portions:"Oats 80g · 1 banana · 1 tbsp honey · 2 toast", protein:"14", carbs:"95", fat:"7"),
            .init(time:"During",  label:"Every 7-8 km",           food:"Dates or banana half — water at every station",              portions:"4-5 dates or ½ banana",                        protein:"0",  carbs:"30", fat:"0"),
            .init(time:"ASAP",    label:"Post-run IMMEDIATELY",   food:"Protein shake + banana, 500ml water + electrolytes",        portions:"1 scoop protein · 1 banana",                  protein:"27", carbs:"32", fat:"3"),
            .init(time:"13:00",   label:"Lunch (1-2hr after)",    food:"BIG meal — rice + chicken + veg, ayran + extra bread",      portions:"250g rice · 200g chicken · mixed veg · 2 bread",protein:"65", carbs:"80", fat:"7"),
            .init(time:"16:00",   label:"Snack",                  food:"Greek yogurt + berries + granola, water",                   portions:"200g yogurt · berries · 30g granola",         protein:"20", carbs:"35", fat:"8"),
            .init(time:"19:00",   label:"Dinner",                 food:"Salmon + pasta + salad, olive oil",                         portions:"150g salmon · 200g pasta",                    protein:"42", carbs:"58", fat:"22"),
        ], totalP:"~168g", totalC:"~330g", totalF:"~47g", totalCal:"~3000 kcal"),

        CSSDayPlan(day:"Sunday", subtitle:"Full Rest Day • Recovery", color: AppTheme.textMuted, meals: [
            .init(time:"8:00",      label:"Breakfast (sleep in!)", food:"Eggs + avocado + whole grain bread, coffee + water", portions:"3 eggs · ½ avocado · 2 slices bread",         protein:"22", carbs:"34", fat:"22"),
            .init(time:"11:00",     label:"Snack",                 food:"Fruit bowl — banana + berries + kiwi, green tea",    portions:"1 banana · 100g berries · 2 kiwi",            protein:"4",  carbs:"52", fat:"1"),
            .init(time:"13:00",     label:"Lunch",                 food:"Chicken + salad + small rice, olive oil dressing",   portions:"150g chicken · 100g rice · big salad",        protein:"43", carbs:"32", fat:"8"),
            .init(time:"16:00",     label:"Snack",                 food:"Cottage cheese + nuts + apple, water + creatine 5g", portions:"150g cottage cheese · 20g walnuts · 1 apple", protein:"20", carbs:"26", fat:"14"),
            .init(time:"19:00",     label:"Dinner",                food:"Salmon or beef + vegetables + sweet potato",         portions:"150g protein · 150g sweet potato · veg",      protein:"37", carbs:"30", fat:"18"),
            .init(time:"Before bed",label:"Optional",              food:"Cottage cheese + honey or warm milk",                 portions:"150g cottage cheese · 1 tsp honey",           protein:"19", carbs:"8",  fat:"5"),
        ], totalP:"~145g", totalC:"~182g", totalF:"~68g", totalCal:"~2200 kcal"),
    ]

    // MARK: Supplements
    static let supplements: [CSSSuppRow] = [
        .init(name:"Creatine Monohydrate", dose:"5g daily",               timing:"Any time — consistency matters",  why:"Increases strength 10-15%, improves endurance, faster recovery, brain function boost", priority:"ESSENTIAL"),
        .init(name:"Vitamin D3 + K2",      dose:"3000 IU D3 + 100mcg K2", timing:"Morning with fat source",         why:"You sit indoors all day. Bone + immune health, testosterone support, muscle function",  priority:"ESSENTIAL"),
        .init(name:"Magnesium Glycinate",  dose:"300-400mg",               timing:"Before bed",                      why:"Sleep quality, muscle cramp prevention, recovery, anxiety reduction",                   priority:"ESSENTIAL"),
        .init(name:"Omega 3 Fish Oil",     dose:"2-3g EPA+DHA",            timing:"With any meal",                   why:"Joint health (you run!), anti-inflammatory, brain function, heart health",              priority:"ESSENTIAL"),
        .init(name:"Whey Protein",         dose:"25-30g per serving",      timing:"Post-workout if needed",          why:"Convenience to hit 136g protein target. Fast absorbing, BCAA content",                  priority:"USEFUL"),
        .init(name:"Vitamin B Complex",    dose:"1 tablet",                 timing:"Morning with food",               why:"Energy metabolism, nerve function, red blood cell production",                          priority:"USEFUL"),
        .init(name:"Zinc",                 dose:"25mg",                     timing:"Evening with food",               why:"Testosterone support, immune function, recovery",                                        priority:"OPTIONAL"),
        .init(name:"Tart Cherry Extract",  dose:"480mg",                    timing:"Post-workout or evening",         why:"Reduces muscle soreness, anti-inflammatory, sleep quality",                             priority:"OPTIONAL"),
        .init(name:"Caffeine (Coffee/Tea)",dose:"100-200mg",               timing:"30-45 min before training",       why:"Performance boost, fat burning, focus + endurance",                                     priority:"NATURAL"),
    ]

    // MARK: Golden nutrition rules
    static let goldenRules: [CSSRule] = [
        .init(number:1,  rule:"Never skip breakfast",        why:"Starts protein synthesis, prevents muscle breakdown overnight"),
        .init(number:2,  rule:"Protein at EVERY meal",       why:"25-40g per meal — body can only use ~40g at once"),
        .init(number:3,  rule:"Carbs around training",       why:"Before = energy. After = glycogen refill. Rest day = reduce carbs"),
        .init(number:4,  rule:"Hit 136g protein daily",      why:"Non-negotiable for muscle growth at 68kg bodyweight"),
        .init(number:5,  rule:"Drink 3.5L water daily",      why:"Performance drops 10% when 2% dehydrated — most people always are"),
        .init(number:6,  rule:"Don't fear fat",              why:"Healthy fats = hormones, joints, vitamins. 70-80g daily is ideal"),
        .init(number:7,  rule:"Eat whole foods 80%",         why:"20% flexible — but 80% real food is the foundation of everything"),
        .init(number:8,  rule:"Post-workout 30 min window",  why:"Protein + fast carbs immediately after training — don't miss this"),
        .init(number:9,  rule:"Sleep = nutrition partner",   why:"8 hours sleep = muscle grows. 5 hours = muscle shrinks. No supplement fixes bad sleep"),
        .init(number:10, rule:"Consistency > perfection",    why:"One bad meal doesn't ruin progress. One week of bad eating does. Be 90% consistent"),
    ]

    // MARK: Workout timing
    static let workoutTiming: [CSSTimingRow] = [
        .init(phase:"Pre-Gym (Strength)",  timing:"1.5-2 hrs before",     eat:"Rice + chicken / oats + protein, banana",           avoid:"High fat, high fiber, large portions",          why:"Glycogen loading, amino acids ready, no digestion issues"),
        .init(phase:"Pre-Run (Endurance)", timing:"1-2 hrs before",        eat:"Banana + dates + water, oats + honey, small coffee", avoid:"Dairy, fiber, large meals, new foods",          why:"Fast carbs only, light stomach, caffeine boost"),
        .init(phase:"During Run (60min+)", timing:"Every 45-60 min",       eat:"Dates, banana half or energy gel, water",            avoid:"Solid food, dairy, high fiber",                why:"Maintain blood glucose, prevent glycogen depletion"),
        .init(phase:"Post-Workout",        timing:"Within 30 min",         eat:"Protein shake + banana/rice, fast carbs",            avoid:"High fat meals (slows absorption), alcohol",   why:"30-min anabolic window, maximum protein synthesis, glycogen refill"),
        .init(phase:"Before Bed",          timing:"1-2 hrs before sleep",  eat:"Cottage cheese / Greek yogurt, casein protein",      avoid:"Large carbs, heavy fat, caffeine",             why:"Slow-release protein, overnight muscle repair, deep sleep"),
    ]

    // MARK: Hydration protocol
    static let hydration: [(timing: String, amount: String, note: String)] = [
        ("Wake up",           "500ml",             "Water + pinch salt — rehydrate after 8hr sleep, kickstart metabolism"),
        ("Before breakfast",  "200ml",             "Water — prepare digestion"),
        ("Morning 9-12",      "500-700ml",         "Water + green tea — stay hydrated at desk"),
        ("Lunch",             "300ml",             "Water or ayran — electrolytes from ayran"),
        ("Afternoon 12-5",    "500-700ml",         "Water — prevents afternoon fatigue"),
        ("Pre-workout",       "500ml",             "Water — pre-load hydration (30-60 min before)"),
        ("During training",   "150-250ml/15 min",  "Water (electrolytes if session > 60 min)"),
        ("Post-workout",      "500ml",             "Water + electrolytes or ayran — immediate rehydration"),
        ("Evening / dinner",  "300ml",             "Water — maintain levels"),
        ("DAILY TOTAL",       "3-3.5 LITERS",      "Ayran is perfect natural electrolyte. Add 200ml per coffee consumed."),
    ]
}
