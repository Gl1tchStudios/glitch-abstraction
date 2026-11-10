-- Cutscene catalog: every GTA V cutscene in the game files (781 .cut files, read from every rpf and DLC pack on
-- 2026-11-04, design/cutscene-dump), sorted into
-- Story Mode / GTA Online / DLC / Rockstar test scenes, with the mission or update it belongs to and a
-- description for each one.
--
-- How a description is made: the first GROUPS rule whose pattern matches the name gives the mission
-- (title + blurb), the rest of the name gives the part (int = opening scene, ext = closing scene,
-- mcs_3 = mid-mission scene 3, rcm = Strangers and Freaks, concat = full version, p2 = part 2 ...).
-- OVERRIDES replace that with a hand-written line. guess = true marks a mission we are not sure of:
-- the admin browser shows it as "unconfirmed", fix the rule here once someone has watched it.
--
-- Used by:
--   GlitchAbst.Cutscene.GetInfo(name)   -> one entry (also works for names not in NAMES)
--   GlitchAbst.Cutscene.GetCatalog()    -> every entry, sorted (source, set, mission, name)
--   exports['glitch-abstraction']:GetCutsceneCatalog() / GetCutsceneInfo(name)  (client and server)
-- Entry: { name, source, sourceLabel, set, mission, part, desc, lead, guess }
--   source = 'story' | 'online' | 'dlc' | 'other'; lead = 'MP_1' when the player can be cast (online / DLC)

local SOURCES = {
    story = { label = 'Story Mode', order = 1 },
    online = { label = 'GTA Online', order = 2 },
    dlc = { label = 'DLC', order = 3 },
    other = { label = 'Rockstar test scenes', order = 4 },
}

-- DLC sets in release order (the browser lists them in this order)
local DLC = {
    heists = 'Heists (2015)',
    lowriders = 'Lowriders (2015)',
    executives = 'Executives and Other Criminals (2015)',
    impexp = 'Import/Export (2016)',
    bikers = 'Bikers (2016)',
    gunrunning = 'Gunrunning (2017)',
    smugglers = "Smuggler's Run (2017)",
    doomsday = 'The Doomsday Heist (2017)',
    afterhours = 'After Hours (2018)',
    arena = 'Arena War (2018)',
    casino = 'The Diamond Casino & Resort (2019)',
    casinoheist = 'The Diamond Casino Heist (2019)',
    cayo = 'The Cayo Perico Heist (2020)',
    tuners = 'Los Santos Tuners (2021)',
    contract = 'The Contract (2021)',
    drugwars = 'Los Santos Drug Wars (2022)',
    mercs = 'San Andreas Mercenaries (2023)',
    chopshop = 'The Chop Shop (2023)',
    bounties = 'Bottom Dollar Bounties (2024)',
    sabotage = 'Agents of Sabotage (2024)',
    fronts = 'Money Fronts (2025)',
    winter25 = 'Winter 2025 update',
    summer26 = 'Summer 2026 update',
    unknown = 'Unsorted DLC',
}
local DLC_ORDER = {}
for i, k in ipairs({ 'heists', 'lowriders', 'executives', 'impexp', 'bikers', 'gunrunning', 'smugglers', 'doomsday', 'afterhours',
    'arena', 'casino', 'casinoheist', 'cayo', 'tuners', 'contract', 'drugwars', 'mercs', 'chopshop', 'bounties', 'sabotage', 'fronts',
    'winter25', 'summer26', 'unknown' }) do DLC_ORDER[DLC[k]] = i end

-- Story sets (storyline order)
local STORY = {
    prologue = 'Prologue', missions = 'Story missions', heists = 'Story heists', finale = 'Finale',
    strangers = 'Strangers and Freaks', side = 'Side content',
}
local STORY_ORDER = { [STORY.prologue] = 1, [STORY.missions] = 2, [STORY.heists] = 3, [STORY.finale] = 4, [STORY.strangers] = 5, [STORY.side] = 6 }

local function S(set, title, blurb, extra) local g = extra or {} g.src, g.set, g.title, g.blurb = 'story', set, title, blurb return g end
local function O(title, blurb, extra) local g = extra or {} g.src, g.set, g.title, g.blurb = 'online', 'GTA Online', title, blurb return g end
local function D(dlc, title, blurb, extra) local g = extra or {} g.src, g.set, g.title, g.blurb = 'dlc', DLC[dlc], title, blurb return g end
local function T(title) return { src = 'other', set = 'Test and leftover scenes', title = title, blurb = 'A Rockstar test or leftover scene, may not load or may show placeholders.' } end

-- First match wins: keep longer / more specific patterns above shorter ones.
local GROUPS = {
    -- Rockstar test / leftover scenes
    { '^carbine_mag', T('Carbine magazine test') }, { '^handposes', T('Hand poses test') }, { '^merge_test', T('Merge test') },
    { '^nextgen_fx', T('Next-gen effects test') }, { '^ng_optimise', T('Next-gen optimisation test') }, { '^testbed', T('Vehicle blend test') },
    { '^test_', T('Test copy of a story scene') },

    -- ---------------------------------------------------------------- Story Mode
    { '^pro_', S(STORY.prologue, 'Prologue', 'North Yankton, 2004: Michael, Trevor and Brad rob the Ludendorff cash depot and it goes wrong.') },
    { '^armenian_1', S(STORY.missions, 'Franklin and Lamar', 'Franklin and Lamar race two of Simeon\'s "repossessed" cars back to the dealership.') },
    { '^arm_1', S(STORY.missions, 'Franklin and Lamar', 'Franklin and Lamar race two of Simeon\'s "repossessed" cars back to the dealership.') },
    { '^armenian_2', S(STORY.missions, 'Repossession', 'Franklin and Lamar take back a bike for Simeon and run into the Ballas.') },
    { '^arm_2', S(STORY.missions, 'Repossession', 'Franklin and Lamar take back a bike for Simeon and run into the Ballas.') },
    { '^armenian_3', S(STORY.missions, 'Complications', 'Franklin tries to repo Jimmy\'s car and finds Michael hiding in the back seat.') },
    { '^fra_0', S(STORY.missions, 'Chop', 'Franklin and Lamar walk Chop and chase a Ballas dealer through the hood.') },
    { '^franklin_1', S(STORY.missions, 'Hood Safari', 'Franklin and Lamar get dragged into a Ballas drug deal that goes bad.') },
    { '^fra_1', S(STORY.missions, 'Hood Safari', 'Franklin and Lamar get dragged into a Ballas drug deal that goes bad.') },
    { '^fra_2', S(STORY.missions, 'Lamar Down', 'Franklin saves Lamar from Stretch\'s set-up at the sawmill.') },
    { '^family_1', S(STORY.missions, 'Father/Son', 'Michael and Franklin chase down Jimmy, who sold his dad\'s yacht off the back of a truck.') },
    { '^fam_1', S(STORY.missions, 'Father/Son', 'Michael and Franklin chase down Jimmy, who sold his dad\'s yacht off the back of a truck.') },
    { '^family_2', S(STORY.missions, 'Daddy\'s Little Girl', 'Michael and Jimmy go cycling, then Michael chases Jimmy on a jet ski.') },
    { '^family_3', S(STORY.missions, 'Marriage Counseling', 'Michael pulls down a house on the hill after finding Amanda with her tennis coach.') },
    { '^fam_3', S(STORY.missions, 'Marriage Counseling', 'Michael pulls down a house on the hill after finding Amanda with her tennis coach.') },
    { '^family_4', S(STORY.missions, 'Fame or Shame', 'Michael and Trevor go after Lazlow after Tracey\'s Fame or Shame audition.') },
    { '^fam_4', S(STORY.missions, 'Fame or Shame', 'Michael and Trevor go after Lazlow after Tracey\'s Fame or Shame audition.') },
    { '^fos_tracey', S(STORY.missions, 'Fame or Shame', 'Tracey on stage at the Fame or Shame audition.', { guess = true }) },
    { '^fos_ep', S(STORY.missions, 'Fame or Shame', 'Fame or Shame show footage around Tracey\'s audition.', { guess = true }) },
    { '^family_5', S(STORY.missions, 'Did Somebody Say Yoga?', 'Yoga with Fabien, a spiked drink and Michael\'s trip.') },
    { '^fam_5', S(STORY.missions, 'Did Somebody Say Yoga?', 'Yoga with Fabien, a spiked drink and Michael\'s trip.') },
    { '^family_6', S(STORY.missions, 'Reuniting the Family', 'Michael takes the whole family to Dr. Friedlander and tries to fix things.') },
    { '^fam_6', S(STORY.missions, 'Reuniting the Family', 'Michael takes the whole family to Dr. Friedlander and tries to fix things.') },
    { '^lamar_1', S(STORY.missions, 'The Long Stretch', 'Franklin and Lamar walk into Stretch\'s set-up with the Ballas and the police.') },
    { '^lam_1', S(STORY.missions, 'The Long Stretch', 'Franklin and Lamar walk into Stretch\'s set-up with the Ballas and the police.') },
    { '^lester_1', S(STORY.missions, 'Friend Request', 'Michael meets Lester and plants a phone bomb at Lifeinvader.') },
    { '^les_1', S(STORY.missions, 'Friend Request', 'Michael meets Lester and plants a phone bomb at Lifeinvader.') },
    { '^trevor_1', S(STORY.missions, 'Mr. Philips', 'Trevor finds out Michael is alive and takes it out on the Lost MC.') },
    { '^trv_1', S(STORY.missions, 'Mr. Philips', 'Trevor finds out Michael is alive and takes it out on the Lost MC.') },
    { '^trevor_2', S(STORY.missions, 'Nervous Ron', 'Trevor and Ron take out the Lost MC deal at the airfield.') },
    { '^trv2', S(STORY.missions, 'Nervous Ron', 'Trevor and Ron take out the Lost MC deal at the airfield.') },
    { '^trv_2', S(STORY.missions, 'Nervous Ron', 'Trevor and Ron take out the Lost MC deal at the airfield.') },
    { '^trevor_drive', S(STORY.missions, 'Trevor heads to Los Santos', 'Trevor drives into the city after Michael.', { guess = true }) },
    { '^trv_dri', S(STORY.missions, 'Trevor heads to Los Santos', 'Trevor drives into the city after Michael.', { guess = true }) },
    { '^trv_4', S(STORY.missions, 'Trevor mission 4', 'One of Trevor\'s Blaine County missions.', { guess = true }) },
    { '^trv_5', S(STORY.missions, 'Trevor mission 5', 'One of Trevor\'s missions.', { guess = true }) },
    { '^chinese_1', S(STORY.missions, 'Trevor Philips Industries', 'Trevor crashes Wei Cheng\'s meeting with Ortega and the Lost.') },
    { '^chi_1', S(STORY.missions, 'Trevor Philips Industries', 'Trevor crashes Wei Cheng\'s meeting with Ortega and the Lost.') },
    { '^chinese_2', S(STORY.missions, 'Crystal Maze', 'Trevor blows up the O\'Neil brothers\' meth farm.') },
    { '^chi_2', S(STORY.missions, 'Crystal Maze', 'Trevor blows up the O\'Neil brothers\' meth farm.') },
    { '^fbi_1', S(STORY.missions, 'Dead Man Walking', 'Michael is pulled back in by Agents Norton and Haines at the morgue.') },
    { '^fbi_2', S(STORY.missions, 'Three\'s Company', 'Michael, Trevor and Franklin grab Mr. K out of the FIB building.') },
    { '^fbi_3', S(STORY.missions, 'By the Book', 'The torture scene: Trevor questions Mr. K while Michael hunts the target.') },
    { '^fbi_4', S(STORY.missions, 'Blitz Play', 'The crew hits the armoured van downtown in garbage-truck disguises.') },
    { '^fbi_5', S(STORY.missions, 'Monkey Business', 'The crew steals the nerve agent from Humane Labs.') },
    { '^martin_1', S(STORY.missions, 'Caida Libre', 'Michael and Trevor steal Madrazo\'s plane mid-air at the wedding.') },
    { '^mic_1', S(STORY.missions, 'Bury the Hatchet', 'Michael and Trevor back in North Yankton for Brad\'s grave.') },
    { '^mic_2', S(STORY.missions, 'Fresh Meat', 'Michael is held by the Triads at the meat plant and Franklin gets him out.') },
    { '^mic_3', S(STORY.missions, 'The Wrap Up', 'Michael meets Dave and Steve at the observatory and it ends in a shoot-out.') },
    { '^mic_4', S(STORY.missions, 'Meltdown', 'Premiere night for Solomon\'s movie Meltdown.') },
    { '^melt_', S(STORY.missions, 'Meltdown (film)', 'Clips from Solomon\'s movie Meltdown, shown at the premiere.', { guess = true }) },
    { '^sol_1', S(STORY.missions, 'Mr. Richards', 'Michael meets Solomon Richards at the studio.') },
    { '^sol_2', S(STORY.missions, 'The Ballad of Rocco', 'Michael deals with Rocco and Gianni for Solomon.') },
    { '^sol_', S(STORY.missions, 'Solomon Richards', 'One of Michael\'s Solomon Richards missions.', { guess = true }) },
    { '^exile_1', S(STORY.missions, 'Minor Turbulence', 'Trevor, Michael and Franklin out of town: the cargo plane job.') },
    { '^exl_1', S(STORY.missions, 'Minor Turbulence', 'Trevor, Michael and Franklin out of town: the cargo plane job.') },
    { '^exile_2', S(STORY.missions, 'Predator', 'Hunting the FIB\'s target from the chopper with Chop.') },
    { '^exl_2', S(STORY.missions, 'Predator', 'Hunting the FIB\'s target from the chopper with Chop.') },
    { '^exile_3', S(STORY.missions, 'Derailed', 'Trevor derails the train for the FIB.') },
    { '^exl_3', S(STORY.missions, 'Derailed', 'Trevor derails the train for the FIB.') },
    { '^car_steal', S(STORY.missions, 'Devin Weston car steals', 'Stealing cars to order for Devin Weston.') },
    { '^car_', S(STORY.missions, 'Devin Weston car steals', 'Stealing cars to order for Devin Weston.', { guess = true }) },
    { '^drf_mic', S(STORY.missions, 'Dr. Friedlander sessions', 'Michael on the couch with his therapist.') },
    { '^ass_', S(STORY.missions, 'Lester\'s assassinations', 'Franklin\'s hits for Lester.') },
    -- story heists
    { '^jh2', S(STORY.heists, 'The Jewel Store Job', 'The Vangelico heist and the getaway through the storm drains.') },
    { '^jh_end', S(STORY.heists, 'The Jewel Store Job', 'The Vangelico heist and the getaway through the storm drains.') },
    { '^jh_2', S(STORY.heists, 'The Jewel Store Job', 'The Vangelico heist and the getaway through the storm drains.') },
    { '^jh_1', S(STORY.heists, 'Casing the Jewel Store', 'Michael scouts Vangelico with Lester\'s glasses camera.') },
    { '^dhp1', S(STORY.heists, 'Scouting the Port', 'Trevor and Floyd scout the Port of Los Santos.') },
    { '^lsdhs', S(STORY.heists, 'The Merryweather Heist: setup', 'Floyd\'s apartment and the run-up to the docks job.') },
    { '^lsdh_2a', S(STORY.heists, 'The Merryweather Heist (Offshore)', 'The underwater approach to the Merryweather freighter.') },
    { '^lsdh_2b', S(STORY.heists, 'The Merryweather Heist (Freighter)', 'Stealing the device straight off the freighter.') },
    { '^lsdh', S(STORY.heists, 'The Merryweather Heist', 'The docks job for the FIB.') },
    { '^rbhs', S(STORY.heists, 'The Paleto Score: setup', 'Trevor\'s crew plans the Paleto Bay bank job.') },
    { '^rbh', S(STORY.heists, 'The Paleto Score', 'The Paleto Bay bank robbery in juggernaut suits.') },
    { '^ah_1', S(STORY.heists, 'The Bureau Raid: planning', 'Lester\'s plan to get into the FIB building.', { guess = true }) },
    { '^ah_2', S(STORY.heists, 'Architect\'s Plans', 'Michael gets the FIB building plans from the architect.') },
    { '^ah_3a', S(STORY.heists, 'The Bureau Raid (Fire Crew)', 'Into the FIB building dressed as firefighters.') },
    { '^ah_3b', S(STORY.heists, 'The Bureau Raid (Roof Entry)', 'Into the FIB building by parachute onto the roof.') },
    { '^bss', S(STORY.heists, 'The Big Score: setup', 'Getting ready for the Union Depository job.') },
    { '^bs_1', S(STORY.heists, 'The Big Score: planning', 'The crew plans the Union Depository gold job.') },
    { '^bs_2a_2b', S(STORY.heists, 'The Big Score', 'The Union Depository gold job.') },
    { '^bs_2a', S(STORY.heists, 'The Big Score (Subtle)', 'The Union Depository job, swapping the gold trucks.') },
    { '^bs_2b', S(STORY.heists, 'The Big Score (Obvious)', 'The Union Depository job, breaking in with a drill.') },
    -- finale
    { '^fin_a', S(STORY.finale, 'Something Sensible', 'Ending A: Franklin goes after Trevor.') },
    { '^fin_b', S(STORY.finale, 'The Time\'s Come', 'Ending B: Franklin goes after Michael.') },
    { '^fin_c', S(STORY.finale, 'The Third Way', 'Ending C: all three go after everyone who wronged them.') },
    { '^fin_ext', S(STORY.finale, 'Ending', 'The very end of the story.') },
    { '^choice', S(STORY.finale, 'The choice', 'Franklin is told to kill Michael or Trevor.') },
    -- Strangers and Freaks
    { '^abigail', S(STORY.strangers, 'Abigail Mathers', 'Michael helps Abigail find her dead husband\'s submarine parts.') },
    { '^bar_', S(STORY.strangers, 'Barry (Grass Roots)', 'Barry\'s weed-legalisation campaign, with a strange smoke each time.') },
    { '^ep_', S(STORY.strangers, 'The Epsilon Program', 'Michael joins the Epsilon cult and does what Cris Formage asks.') },
    { '^eps_', S(STORY.strangers, 'The Epsilon Program', 'Michael joins the Epsilon cult and does what Cris Formage asks.') },
    { '^ef_', S(STORY.strangers, 'Mary-Ann (Exercising Demons)', 'Franklin races Mary-Ann.', { guess = true }) },
    { '^es_', S(STORY.strangers, 'Dom Beverly (Extreme Sports)', 'Franklin follows Dom on his stunts.') },
    { '^pap_', S(STORY.strangers, 'Beverly (Paparazzo)', 'Franklin chases celebrity photos with Beverly.') },
    { '^paper', S(STORY.strangers, 'Unnamed Strangers and Freaks mission', 'Not matched to a mission yet.', { guess = true }) },
    { '^nmt_', S(STORY.strangers, 'Nigel and Mrs. Thornhill', 'Trevor collects celebrity souvenirs for two stalkers.') },
    { '^mmb_', S(STORY.strangers, 'Joe and Josef (Minute Men)', 'Trevor helps the "civil border patrol".', { guess = true }) },
    { '^tmom', S(STORY.strangers, 'Mrs. Philips', 'Trevor\'s mother pays a visit.') },
    { '^josh', S(STORY.strangers, 'Josh Bernstein', 'Trevor helps a failing estate agent with an arson job.') },
    { '^maude', S(STORY.strangers, 'Maude (bail bonds)', 'Trevor picks up bail jumpers for Maude.') },
    { '^tonya', S(STORY.strangers, 'Tonya (towing)', 'Franklin covers Tonya\'s towing shifts.') },
    { '^cletus', S(STORY.strangers, 'Cletus (hunting)', 'Trevor goes hunting with Cletus.') },
    { '^hun_', S(STORY.strangers, 'Cletus (hunting)', 'Trevor goes hunting with Cletus.') },
    { '^sas_', S(STORY.strangers, 'The Last One', 'Franklin and the hunter track the Sasquatch.', { guess = true }) },
    { '^scrap', S(STORY.strangers, 'Unnamed Strangers and Freaks mission', 'Not matched to a mission yet.', { guess = true }) },
    { '^oscar', S(STORY.strangers, 'Oscar', 'Trevor and Oscar at the airfield.', { guess = true }) },
    { '^sdrm', S(STORY.strangers, 'Unnamed Strangers and Freaks mission', 'Not matched to a mission yet.', { guess = true }) },
    -- side content
    { '^trvram', S(STORY.side, 'Trevor\'s rampages', 'Trevor snaps and goes on a rampage.') },
    { '^ac_', S(STORY.side, 'Altruist Cult', 'The Altruist Cult random event in the hills.', { guess = true }) },

    -- ---------------------------------------------------------------- GTA Online
    { '^mp_intro', O('GTA Online intro', 'Your character lands at LSIA and Lamar shows you round the city.') },
    { '^mp_int_', O('GTA Online intro', 'The first-day scenes with Lamar and the early contacts.') },
    { '^gen9_mig', O('Character transfer intro', 'The Expanded and Enhanced intro for moving a character to the new consoles.') },
    { '^hao', O('Hao\'s Special Works', 'Hao and the Expanded and Enhanced car upgrades.', { guess = true }) },
    { '^mpsui', D('casino', 'Casino scene (mpsui)', 'A scene from the Diamond Casino pack.', { guess = true }) },
    { '^tale_', D('afterhours', 'After Hours intro (tale)', 'An After Hours scene.', { guess = true }) },

    -- ---------------------------------------------------------------- DLC
    { '^heist_int', D('heists', 'Heists intro', 'Lester calls you in to start doing heists.') },
    { '^mph_tut', D('heists', 'The Fleeca Job', 'The first heist: Lester and the Fleeca bank on the Great Ocean Highway.') },
    { '^mph_pri', D('heists', 'The Prison Break', 'Breaking Rashkovsky out of Bolingbroke.') },
    { '^mph_hum', D('heists', 'The Humane Labs Raid', 'Stealing the EMP from Humane Labs.') },
    { '^mph_nar', D('heists', 'Series A Funding', 'Trevor\'s drug-dealing job for the Series A.') },
    { '^mph_pac', D('heists', 'The Pacific Standard Job', 'The big Pacific Standard bank robbery.') },
    { '^mph_fin_cel', D('heists', 'Heist celebration', 'The after-party once a heist finale pays out.') },
    { '^low', D('lowriders', 'Lowriders', 'Lamar\'s lowrider missions with Benny.') },
    { '^apa_', D('executives', 'Heists in the new apartments', 'Heist scenes set in the Executives stilt and Eclipse apartments.') },
    { '^impexp', D('impexp', 'Import/Export', 'The vehicle warehouse intro.') },
    -- bmad / smun / tale: in the After Hours pack (mpbattle) in the game files, whatever the names suggest
    { '^bmad', D('afterhours', 'After Hours intro (bmad)', 'An After Hours scene.', { guess = true }) },
    { '^bunk', D('gunrunning', 'Bunker intro', 'Agent 14 and your first bunker.') },
    { '^smun', D('afterhours', 'After Hours intro (smun)', 'An After Hours scene.', { guess = true }) },
    { '^hang_', D('smugglers', 'Hangar intro', 'Your first look round the hangar.') },
    { '^iaaj', D('doomsday', 'The Data Breaches', 'Act 1 of the Doomsday Heist, around the IAA.', { guess = true }) },
    { '^iaa_', D('doomsday', 'The Doomsday Heist intro', 'Lester, Agent 14 and the facility.') },
    { '^subj', D('doomsday', 'The Bogdan Problem', 'Act 2: the submarine.', { guess = true }) },
    { '^sub_', D('doomsday', 'The Bogdan Problem', 'Act 2: the submarine.', { guess = true }) },
    { '^silj', D('doomsday', 'The Doomsday Scenario', 'Act 3: the missile silo and Avon.', { guess = true }) },
    { '^sil_', D('doomsday', 'The Doomsday Scenario', 'Act 3: the missile silo and Avon.', { guess = true }) },
    { '^club_', D('afterhours', 'Nightclub', 'Tony Prince and your nightclub.') },
    { '^dixn', D('afterhours', 'DJ Dixon', 'Dixon arrives at the club.') },
    { '^arena', D('arena', 'Arena War', 'The Arena War intro.') },
    { '^mpcas', D('casino', 'Casino story missions', 'Agatha Baker, Tao Cheng and the Diamond.') },
    { '^hs3f', D('casinoheist', 'The Diamond Casino Heist: finale', 'Robbing the Diamond\'s vault.') },
    { '^hs3', D('casinoheist', 'The Diamond Casino Heist', 'Lester and the arcade, planning the Diamond job.') },
    { '^hs4f', D('cayo', 'The Cayo Perico Heist: finale', 'The raid on El Rubio\'s island.') },
    { '^hs4', D('cayo', 'The Cayo Perico Heist', 'Miguel Madrazo, the Kosatka and scoping Cayo Perico.') },
    { '^tunf', D('tuners', 'Tuner contracts: finales', 'The big finish of KDJ and Sessanta\'s contracts.') },
    { '^tun_', D('tuners', 'Los Santos Tuners', 'The LS Car Meet and your auto shop.') },
    { '^fixf', D('contract', 'Don\'t F*** With Dre', 'The finale of Dr. Dre\'s contract.') },
    { '^fix_trip', D('contract', 'Short Trips', 'Franklin and Lamar\'s Short Trips.') },
    { '^fix_', D('contract', 'The Contract', 'Franklin\'s agency, Imani and Dr. Dre\'s stolen phone.') },
    { '^xm3_drg1', D('drugwars', 'The First Dose', 'Dax and the Fooliganz.') },
    { '^xm3_drg2', D('drugwars', 'The Last Dose', 'The second half of the Drug Wars story.') },
    { '^xm3', D('drugwars', 'Los Santos Drug Wars', 'The Drug Wars story.') },
    { '^sum23', D('mercs', 'San Andreas Mercenaries', 'Charlie, Avenger missions and the Mercenaries story.', { guess = true }) },
    { '^xm4_cbr', D('chopshop', 'Cluckin\' Bell Farm Raid', 'The farm raid job.', { guess = true }) },
    { '^xm4_rob', D('chopshop', 'Salvage Yard robberies', 'Vehicle robberies for the salvage yard.') },
    { '^xm4_yard', D('chopshop', 'Salvage Yard', 'Your salvage yard.') },
    { '^xm4', D('chopshop', 'The Chop Shop', 'The Chop Shop update.', { guess = true }) },
    { '^sum24', D('bounties', 'Bottom Dollar Bounties', 'Bail office bounty hunting.') },
    { '^xm24', D('sabotage', 'Agents of Sabotage', 'The factory and the sabotage jobs.') },
    { '^sum25', D('fronts', 'Money Fronts', 'Summer 2025 update scenes.', { guess = true }) },
    { '^xm25', D('winter25', 'Winter 2025 update', 'Winter 2025 update scenes, with Avi and the mansion.', { guess = true }) },
    { '^sum26_kortz', D('summer26', 'The Kortz Center job', 'The Summer 2026 heist at the Kortz Center.', { guess = true }) },
    { '^sum26', D('summer26', 'Summer 2026 update', 'Summer 2026 update scenes.', { guess = true }) },
    -- jhrs / under: base game files (x64c.rpf), not DLC
    { '^jhrs', S(STORY.heists, 'The Jewel Store Job: extra scenes', 'Extra Jewel Store Job scenes, not matched to a moment yet.', { guess = true }) },
    { '^under', { src = 'other', set = 'Test and leftover scenes', title = 'Unsorted base game scene (under)', blurb = 'In the base game files, not matched to a mission yet.', guess = true } },
}

-- Hand-written lines (replace the generated "mission - part. blurb")
local OVERRIDES = {
    mp_intro_concat = 'GTA Online opening, short cut: you land at LSIA and Lamar picks you up.',
    mp_intro = 'GTA Online opening: you land at LSIA and Lamar picks you up.',
    heist_int = 'Lester calls you in and the Heists update starts.',
    mph_tut_int = 'Lester briefs the crew on The Fleeca Job.',
    mph_pri_int = 'Lester briefs the crew on The Prison Break.',
    mph_hum_int = 'Lester briefs the crew on The Humane Labs Raid.',
    mph_nar_int = 'Trevor briefs the crew on Series A Funding.',
    mph_pac_int = 'Lester briefs the crew on The Pacific Standard Job.',
    mph_fin_cel_apt = 'Heist celebration back at the apartment.',
    mph_fin_cel_apt1 = 'Heist celebration back at the apartment (second version).',
    mph_fin_cel_bar = 'Heist celebration at a bar.',
    mph_fin_cel_roo = 'Heist celebration on a rooftop.',
    mph_fin_cel_str = 'Heist celebration at the strip club.',
    mph_fin_cel_tre = 'Heist celebration at Trevor\'s trailer.',
    apa_fin_cel_apt2 = 'Heist celebration in an Executives apartment (version 2).',
    apa_fin_cel_apt3 = 'Heist celebration in an Executives apartment (version 3).',
    apa_fin_cel_apt4 = 'Heist celebration in an Executives apartment (version 4).',
    hs4_lsa_take_vel = 'The Velum takes off from LSIA for Cayo Perico.',
    hs4_lsa_take_nimb2 = 'The Nimbus takes off from LSIA for Cayo Perico.',
    hs4_lsa_land_vel = 'The Velum lands back at LSIA.',
    hs4_lsa_land_nimb = 'The Nimbus lands back at LSIA.',
    hs4_isd_take_vel = 'The Velum takes off from Cayo Perico.',
    hs4_isd_take_nimb2 = 'The Nimbus takes off from Cayo Perico.',
    hs4_nimb_lsa_isd = 'On board the Nimbus, LSIA to Cayo Perico.',
    hs4_nimb_lsa_isd_repeat = 'On board the Nimbus, LSIA to Cayo Perico (repeat visit).',
    hs4_nimb_isd_lsa = 'On board the Nimbus, Cayo Perico back to LSIA.',
    hs4_vel_lsa_isd = 'On board the Velum, LSIA to Cayo Perico.',
    hs4_scp_bch = 'Scoping Cayo Perico: arriving on the beach.',
    hs4_scp_cctv = 'Scoping Cayo Perico: the compound cameras.',
    hs4_scp_knck = 'Scoping Cayo Perico: knocked out at the party.',
    hs4_scp_push = 'Scoping Cayo Perico: pushed out at the party.',
    hs4_bch_end = 'The beach party ends.',
    hs4_cas_int = 'Miguel Madrazo meets you at the casino penthouse to start the Cayo Perico Heist.',
    hs4_sub_int = 'Your first look round the Kosatka submarine.',
    hs4f_app_heli = 'Cayo Perico finale: flying in by helicopter.',
    hs4f_app_plne = 'Cayo Perico finale: flying in by plane.',
    hs4f_app_sub = 'Cayo Perico finale: arriving by the Kosatka.',
    hs4f_drp_cel = 'Cayo Perico finale: dropping the loot and celebrating.',
    hs4f_drp_off = 'Cayo Perico finale: dropping the loot off.',
    hs4f_main_ent = 'Cayo Perico finale: in through the main gate.',
    hs4f_nrp_ent = 'Cayo Perico finale: in over the north wall.',
    hs4f_ssg_ent = 'Cayo Perico finale: in through the south gate.',
    hs4f_tro_ent = 'Cayo Perico finale: in on the supply truck.',
    hs4f_tun_ent = 'Cayo Perico finale: in through the drainage tunnel.',
    hs3_arc_int = 'Lester shows you round the arcade.',
    hs3_cel_arc = 'Casino heist celebration at the arcade.',
    hs3_prp_celb = 'Casino heist prep: celebration.',
    hs3f_all_drp1 = 'Casino heist finale: the loot drop-off (version 1).',
    hs3f_all_drp2 = 'Casino heist finale: the loot drop-off (version 2).',
    hs3f_all_drp3 = 'Casino heist finale: the loot drop-off (version 3).',
    hs3f_all_esc = 'Casino heist finale: the escape.',
    hs3f_all_esc_b = 'Casino heist finale: the escape (version B).',
    hs3f_dir_ent = 'Casino heist finale, Aggressive approach: going in.',
    hs3f_dir_sew = 'Casino heist finale, Aggressive approach: through the sewer.',
    hs3f_sub_vlt = 'Casino heist finale, Big Con approach: in the vault.',
    hs3f_sub_cel = 'Casino heist finale, Big Con approach: celebration.',
    hs3f_mul_vlt = 'Casino heist finale: in the vault.',
    tunf_uni_swat = 'Union Depository Contract finale: the SWAT disguise.',
    tunf_uni_vlt = 'Union Depository Contract finale: in the vault.',
    tunf_iaa_mcs1 = 'The Data Contract finale at the IAA.',
    xm25_mansion_inta = 'Your new mansion: the tour (version A).',
    xm25_mansion_intb = 'Your new mansion: the tour (version B).',
    xm25_mansion_intc = 'Your new mansion: the tour (version C).',
    sum25_lsia_int = 'A summer 2025 scene at LSIA.',
    choice_int = 'Devin and the FIB each tell Franklin to kill one of his friends.',
    fbi_1_jan_kill = 'Dead Man Walking: the janitor scene.',
}

-- Every name, alphabetical (from DurtyFree gta-v-data-dumps cutsceneNames.json, the b2545 / b2802 lists and later DLC)
local NAMES = {
    'abigail_mcs_1_concat', 'abigail_mcs_2', 'ac_ig_3_p3_b', 'ah_1_ext_t6', 'ah_1_int', 'ah_1_mcs_1', 'ah_2_ext_alt',
    'ah_2_ext_p4', 'ah_3a_explosion', 'ah_3a_ext', 'ah_3a_int', 'ah_3a_mcs_3', 'ah_3a_mcs_6', 'ah_3b_ext',
    'ah_3b_int', 'ah_3b_mcs_1', 'ah_3b_mcs_2', 'ah_3b_mcs_3', 'ah_3b_mcs_4', 'ah_3b_mcs_5', 'ah_3b_mcs_6_p1',
    'ah_3b_mcs_7', 'apa_fin_cel_apt2', 'apa_fin_cel_apt3', 'apa_fin_cel_apt4', 'apa_hum_fin_int', 'apa_nar_int',
    'apa_nar_mid', 'apa_pri_int', 'arena_int', 'arena_int2', 'arm_1_mcs_2_concat', 'arm_2_mcs_4', 'armenian_1_int',
    'armenian_1_mcs_1', 'armenian_2_int', 'armenian_2_mcs_6', 'armenian_3_int', 'armenian_3_mcs_3',
    'armenian_3_mcs_4', 'armenian_3_mcs_5', 'armenian_3_mcs_6', 'armenian_3_mcs_7', 'armenian_3_mcs_8',
    'armenian_3_mcs_9_concat', 'ass_int_2_alt1', 'ass_mcs_1', 'bar_1_rcm_p2', 'bar_2_rcm', 'bar_3_rcm', 'bar_4_rcm',
    'bar_5_rcm_p2', 'bmad_intro', 'bs_1_int', 'bs_2a_2b_int', 'bs_2a_ext', 'bs_2a_int', 'bs_2a_mcs_1', 'bs_2a_mcs_10',
    'bs_2a_mcs_11', 'bs_2a_mcs_2', 'bs_2a_mcs_3_alt', 'bs_2a_mcs_4', 'bs_2a_mcs_5', 'bs_2a_mcs_6', 'bs_2a_mcs_7_p1',
    'bs_2a_mcs_8', 'bs_2a_mcs_8_p3', 'bs_2b_ext_alt1a', 'bs_2b_ext_alt2', 'bs_2b_int', 'bs_2b_mcs_1', 'bs_2b_mcs_3',
    'bss_1_mcs_2', 'bss_1_mcs_3', 'bunk_int', 'car_1_ext_concat', 'car_1_int_concat', 'car_2_mcs_1',
    'car_2_mcs_1_merged', 'car_4_ext', 'car_4_mcs_1', 'car_5_ext', 'car_5_mcs_1', 'car_steal_3_mcs_1',
    'car_steal_3_mcs_2', 'car_steal_3_mcs_3', 'carbine_mag_offset_test', 'chi_1_mcs_1', 'chi_1_mcs_4_concat',
    'chi_2_mcs_5', 'chinese_1_int', 'chinese_2_int', 'choice_int', 'cletus_mcs_1_concat', 'club_intro', 'club_intro2',
    'club_open', 'dhp1_mcs_1', 'dixn_intro', 'drf_mic_1_cs_1', 'drf_mic_1_cs_2', 'drf_mic_2_cs_1', 'drf_mic_2_cs_2',
    'drf_mic_3_cs_1', 'drf_mic_3_cs_2', 'ef_1_rcm', 'ef_2_rcm', 'ef_3_rcm_concat', 'ep_1_rcm_concat', 'ep_2_rcm',
    'ep_3_rcm_alt1', 'ep_4_rcm', 'ep_4_rcm_concat', 'ep_5_rcm', 'ep_6_rcm', 'ep_7_rcm', 'ep_8_rcm', 'eps_4_mcs_1',
    'eps_4_mcs_2', 'eps_4_mcs_3', 'es_1_rcm_concat', 'es_1_rcm_p1', 'es_2_rcm_concat', 'es_3_mcs_1', 'es_3_mcs_2',
    'es_3_rcm', 'es_4_rcm_p1', 'es_4_rcm_p2_concat', 'exile_1_int', 'exile_2_int', 'exile_3_int', 'exl_1_mcs_1_p3_b',
    'exl_2_mcs_3', 'exl_3_ext', 'fam_1_ext_2', 'fam_1_ext_alt2', 'fam_1_ext_alt3', 'fam_1_mcs_2', 'fam_3_mcs_1',
    'fam_3_mcs_1_b', 'fam_4_int_alt1', 'fam_5_mcs_6', 'fam_5_mcs_6_p3_b', 'fam_5_mcs_6_p4', 'fam_6_int',
    'fam_6_int_p3_t7', 'fam_6_mcs_1', 'fam_6_mcs_2_concat', 'fam_6_mcs_3', 'fam_6_mcs_4', 'fam_6_mcs_5',
    'fam_6_mcs_6', 'fam_6_mcs_6_p4_b', 'family_1_int', 'family_2_int', 'family_2_mcs_2', 'family_2_mcs_3',
    'family_2_mcs_4', 'family_3_ext', 'family_3_int', 'family_3_intp1', 'family_3_intp1_2', 'family_3_intp1_3',
    'family_3_intp2', 'family_3_intp2_1', 'family_3_mcs_1', 'family_4_mcs_2', 'family_4_mcs_3_concat', 'family_5_int',
    'family_5_mcs_1', 'family_5_mcs_2', 'family_5_mcs_3', 'family_5_mcs_4', 'family_5_mcs_5', 'family_5_mcs_5_p4',
    'family_5_mcs_5_p5', 'fbi_1_ext', 'fbi_1_int', 'fbi_1_jan_kill', 'fbi_1_mcs_1_concat', 'fbi_2_ext', 'fbi_2_int',
    'fbi_2_mcs_1', 'fbi_2_mcs_2', 'fbi_2_mcs_3_p1a', 'fbi_2_mcs_3b', 'fbi_3_int', 'fbi_3_mcs_1', 'fbi_3_mcs_2',
    'fbi_3_mcs_3', 'fbi_3_mcs_4p2', 'fbi_3_mcs_5', 'fbi_3_mcs_5p2', 'fbi_3_mcs_6p1_b', 'fbi_3_mcs_6p2', 'fbi_3_mcs_7',
    'fbi_3_mcs_8', 'fbi_4_int', 'fbi_4_mcs_2_concat', 'fbi_4_mcs_3_concat', 'fbi_5_ext', 'fbi_5_int', 'fbi_5a_mcs_1',
    'fbi_5a_mcs_10', 'fbi_5b_mcs_1', 'fin_a_ext', 'fin_a_int', 'fin_a_mcs_1', 'fin_b_ext', 'fin_b_mcs_1_aandb',
    'fin_b_mcs_2', 'fin_c2_mcs_1', 'fin_c2_mcs_5', 'fin_c_ext', 'fin_c_int', 'fin_c_mcs_1', 'fin_c_mcs_1_p1_a',
    'fin_ext_p1', 'fin_ext_p2', 'fix_agy_int1', 'fix_agy_int2', 'fix_agy_int3', 'fix_art_ext', 'fix_art_int',
    'fix_bil_mcs1', 'fix_bil_mcs2', 'fix_golf_ext', 'fix_golf_int', 'fix_low_mcs1', 'fix_low_mcs2', 'fix_pro_mcs1',
    'fix_prod_ext', 'fix_prod_int', 'fix_set_mcs1', 'fix_stu_ext', 'fix_stu_mcs1', 'fix_trip1_ext', 'fix_trip1_int',
    'fix_trip1_mcs1', 'fix_trip1_mcs2', 'fix_trip1_mcs3', 'fix_trip2_ext', 'fix_trip2_int', 'fix_trip2_mcs1',
    'fix_trip3_ext', 'fix_trip3_int', 'fix_trip3_mcs1', 'fix_trk_mcs2', 'fix_weed_ext', 'fix_weed_int', 'fix_wrm_int',
    'fixf_fin_mcs1', 'fixf_fin_mcs2', 'fixf_fin_mcs3', 'fos_ep_1_p0', 'fos_ep_1_p1', 'fos_ep_1_p2', 'fos_ep_1_p3',
    'fos_ep_1_p3b', 'fos_ep_1_p3c', 'fos_ep_1_p3d', 'fos_ep_1_p3e', 'fos_ep_1_p4', 'fos_ep_1_p5', 'fos_ep_1_p5b',
    'fos_ep_1_p6', 'fos_ep_1_p6b', 'fos_ep_1_p7', 'fos_ep_1_p8', 'fos_ep_1_p9', 'fos_ep_2_p1', 'fos_ep_2_p2',
    'fos_ep_2_p3', 'fos_ep_2_p5b', 'fos_ep_2_p5c', 'fos_ep_2_p5d', 'fos_ep_2_p6_alt1', 'fos_tracey_1_p1',
    'fos_tracey_1_p2', 'fos_tracey_1_p2b', 'fos_tracey_1_p3', 'fra_0_int', 'fra_0_int_p1_alt', 'fra_0_mcs_1',
    'fra_0_mcs_4_p2_t3', 'fra_0_mcs_5_p1', 'fra_1_mcs_1', 'fra_2_ext', 'fra_2_ig_4_alt1_concat', 'fra_2_int',
    'franklin_1_int', 'franklin_1_intp1', 'franklin_1_intp2', 'franklin_1_intp3', 'gen9_mig_int',
    'gen9_mig_int_p1_t00', 'handposes', 'hang_int', 'hang_int_plane', 'hao_mcs_1', 'heist_int', 'hs3_arc_int',
    'hs3_cel_arc', 'hs3_ext', 'hs3_int', 'hs3_pln_int', 'hs3_prp_celb', 'hs3_prp_vin1', 'hs3_prp_vin2',
    'hs3f_all_drp1', 'hs3f_all_drp2', 'hs3f_all_drp3', 'hs3f_all_esc', 'hs3f_all_esc_b', 'hs3f_dir_ent',
    'hs3f_dir_sew', 'hs3f_int1', 'hs3f_int2', 'hs3f_mul_rp1', 'hs3f_mul_rp2', 'hs3f_mul_vlt', 'hs3f_sub_cel',
    'hs3f_sub_vlt', 'hs4_bch_end', 'hs4_cas_int', 'hs4_isd_take_nimb2', 'hs4_isd_take_vel', 'hs4_lsa_land_nimb',
    'hs4_lsa_land_vel', 'hs4_lsa_take_nimb2', 'hs4_lsa_take_vel', 'hs4_nimb_isd_lsa', 'hs4_nimb_lsa_isd',
    'hs4_nimb_lsa_isd_repeat', 'hs4_scp_bch', 'hs4_scp_cctv', 'hs4_scp_knck', 'hs4_scp_push', 'hs4_sub_int',
    'hs4_vel_lsa_isd', 'hs4f_app_heli', 'hs4f_app_plne', 'hs4f_app_sub', 'hs4f_drp_cel', 'hs4f_drp_off', 'hs4f_ext',
    'hs4f_int', 'hs4f_main_ent', 'hs4f_main_ext', 'hs4f_nrp_ent', 'hs4f_ssg_ent', 'hs4f_ssg_ext', 'hs4f_tro_ent',
    'hs4f_tun_ent', 'hun_2_mcs_1', 'iaa_int', 'iaaj_ext', 'iaaj_int', 'impexp_int', 'impexp_int_l1',
    'jh2_fina_mcs4_a1a2', 'jh_1_ig_3', 'jh_1_int', 'jh_1_mcs_4_p1_alt1', 'jh_1_mcs_4p2', 'jh_2_arrest_fail_c',
    'jh_2_celeb', 'jh_2_fin_a_mcs4_a1', 'jh_2a_intp4', 'jh_2a_mcs_1', 'jh_2b_int', 'jh_2b_mcs_1',
    'jh_end_pt2_a1_p2_a', 'jhrs_1_int_p2', 'jhrs_1_int_p3', 'jhrs_1_int_p4', 'jhrs_2_hero_shot', 'jhrs_2_hero_shot_a',
    'jhrs_2_int_p1_t2', 'jhrs_2_int_p1_t3', 'jhrs_2_int_p2', 'jhrs_2_int_p2_t5', 'jhrs_2_int_p3_t2',
    'jhrs_2_int_p3_t3', 'jhrs_2_int_p3a', 'jhrs_2_int_p4', 'jhrs_2_int_p5', 'jhrs_2_int_p6', 'jhrs_3_int_p2a',
    'jhrs_4_int_p1', 'jhrs_5_int_p1', 'jhrs_5_int_p1b', 'jhrs_5_int_p2', 'jhrs_5_int_p3_t1', 'jhrs_5_int_p3_t3',
    'jhrs_6_int_p1', 'jhrs_6_int_p2', 'jhrs_6_int_p3', 'jhrs_6_int_p4', 'josh_1_int', 'josh_1_int_concat',
    'josh_2_intp1_t4', 'josh_3_intp1', 'josh_4_int_concat', 'lam_1_mcs_1_concat', 'lam_1_mcs_2', 'lam_1_mcs_3',
    'lamar_1_int', 'les_1a_mcs_0', 'les_1a_mcs_1', 'les_1a_mcs_2', 'les_1a_mcs_3', 'les_1a_mcs_4', 'les_1b_mcs_1',
    'lester_1_int', 'low_drv_ext', 'low_drv_int', 'low_fin_ext', 'low_fin_int', 'low_fin_mcs1', 'low_fun_ext',
    'low_fun_int', 'low_fun_mcs1', 'low_int', 'low_pho_ext', 'low_pho_int', 'low_tra_ext', 'low_tra_int',
    'lsdh_2a_ext', 'lsdh_2a_int', 'lsdh_2a_rf_01', 'lsdh_2b_int', 'lsdh_2b_mcs_1', 'lsdh_int', 'lsdhs_mcs_2',
    'lsdhs_mcs_3_p1_concat', 'lsdhs_mcs_3_p2', 'martin_1_ext', 'martin_1_int', 'martin_1_mcs_1', 'maude_mcs_1',
    'maude_mcs_2', 'maude_mcs_3', 'maude_mcs_4', 'maude_mcs_5', 'melt_int_10_p1', 'melt_int_10_p2', 'melt_int_1_p1',
    'melt_int_1_p1_t4', 'melt_int_1_p2', 'melt_int_2', 'melt_int_3', 'melt_int_4', 'melt_int_5', 'melt_int_6',
    'melt_int_7', 'melt_int_8_p1', 'melt_int_8_p2', 'melt_int_8_p3', 'melt_int_9', 'merge_test_crowd1',
    'merge_test_doug', 'mic_1_int', 'mic_1_mcs_1', 'mic_1_mcs_2', 'mic_1_mcs_3', 'mic_2_int', 'mic_2_mcs_1',
    'mic_2_mcs_3_concat', 'mic_3_ext', 'mic_3_int', 'mic_3_int_p1_alt', 'mic_3_mcs_1_p1_a2', 'mic_4_int', 'mmb_1_rcm',
    'mmb_2_rcm', 'mmb_3_rcm', 'mp_int_mcs_12_a3_3', 'mp_int_mcs_12_a3_4', 'mp_int_mcs_15_a1_b', 'mp_int_mcs_15_a2b',
    'mp_int_mcs_15_a3', 'mp_int_mcs_15_a4', 'mp_int_mcs_17_a1', 'mp_int_mcs_17_a2', 'mp_int_mcs_17_a3',
    'mp_int_mcs_17_a4', 'mp_int_mcs_17_a6', 'mp_int_mcs_17_a7', 'mp_int_mcs_18_a1', 'mp_int_mcs_18_a2',
    'mp_int_mcs_5_alt1', 'mp_int_mcs_5_alt2', 'mp_int_mcs_7_a1', 'mp_intro_concat', 'mp_intro_mcs_10_a1',
    'mp_intro_mcs_10_a2', 'mp_intro_mcs_10_a3', 'mp_intro_mcs_10_a4', 'mp_intro_mcs_10_a5', 'mp_intro_mcs_11',
    'mp_intro_mcs_11_a1', 'mp_intro_mcs_12_a1', 'mp_intro_mcs_12_a2', 'mp_intro_mcs_12_a3', 'mp_intro_mcs_13',
    'mp_intro_mcs_14_b', 'mp_intro_mcs_16_a1', 'mp_intro_mcs_16_a2', 'mp_intro_mcs_17_a5', 'mp_intro_mcs_17_a8',
    'mp_intro_mcs_17_a9', 'mp_intro_mcs_8_a1', 'mp_intro_mcs_8_a1_cc', 'mpcas1_ext', 'mpcas1_int', 'mpcas2_ext',
    'mpcas2_int', 'mpcas2_mcs1', 'mpcas3_ext', 'mpcas3_int', 'mpcas3_mcs1', 'mpcas4_int', 'mpcas5_ext', 'mpcas5_int',
    'mpcas6_ext', 'mpcas6_int', 'mpcas6_mcs1', 'mpcas_int', 'mph_fin_cel_apt', 'mph_fin_cel_apt1', 'mph_fin_cel_bar',
    'mph_fin_cel_roo', 'mph_fin_cel_str', 'mph_fin_cel_tre', 'mph_hum_arm_ext', 'mph_hum_del_ext', 'mph_hum_emp_ext',
    'mph_hum_fin_ext', 'mph_hum_fin_int', 'mph_hum_fin_mcs1', 'mph_hum_int', 'mph_hum_key_ext', 'mph_hum_key_mcs1',
    'mph_hum_mid', 'mph_hum_val_ext', 'mph_nar_bik_ext', 'mph_nar_cok_ext', 'mph_nar_fin_ext', 'mph_nar_fin_int',
    'mph_nar_int', 'mph_nar_met_ext', 'mph_nar_mid', 'mph_nar_tra_ext', 'mph_nar_wee_ext', 'mph_pac_bik_ext',
    'mph_pac_con_ext', 'mph_pac_fin_ext', 'mph_pac_fin_int', 'mph_pac_fin_mcs0', 'mph_pac_fin_mcs1',
    'mph_pac_fin_mcs2', 'mph_pac_hac_ext', 'mph_pac_hac_mcs1', 'mph_pac_int', 'mph_pac_mid', 'mph_pac_pho_ext',
    'mph_pac_wit_mcs1', 'mph_pac_wit_mcs2', 'mph_pri_bus_ext', 'mph_pri_fin_ext', 'mph_pri_fin_int',
    'mph_pri_fin_mcs1', 'mph_pri_fin_mcs2', 'mph_pri_int', 'mph_pri_mid', 'mph_pri_pla_ext', 'mph_pri_sta_ext',
    'mph_pri_sta_mcs1', 'mph_pri_sta_mcs2', 'mph_pri_unf_ext', 'mph_pri_unf_mcs1', 'mph_tut_car_ext', 'mph_tut_ext',
    'mph_tut_fin_int', 'mph_tut_int', 'mph_tut_mcs1', 'mph_tut_mid', 'mpsui_int', 'nextgen_fx_test',
    'ng_optimise_concat', 'ng_optimise_test', 'nmt_1_rcm', 'nmt_2_mcs_2', 'nmt_2_rcm', 'nmt_3_rcm', 'oscar_mcs_1',
    'pap_1_mcs_1', 'pap_1_rcm', 'pap_2_mcs_1', 'pap_2_rcm_p2', 'pap_3_rcm', 'pap_4_rcm', 'paper_1_rcm_alt1',
    'pro_mcs_1', 'pro_mcs_2', 'pro_mcs_3_pt1', 'pro_mcs_5', 'pro_mcs_6', 'pro_mcs_6_p1', 'pro_mcs_6_p2_a1_b',
    'pro_mcs_6_p2_alt1', 'pro_mcs_7_concat', 'rbh_2a_ext1_a1_p1', 'rbh_2a_ext_1', 'rbh_2a_int', 'rbh_2a_mcs_2_p3',
    'rbh_2a_mcs_2_p7', 'rbh_2a_mcs_4', 'rbh_2a_mcs_5', 'rbh_2ab_mcs_6', 'rbhs_int', 'rbhs_mcs_1', 'rbhs_mcs_3',
    'rbhs_msc_3_p3', 'sas_1_rcm_concat', 'sas_2_rcm_t7', 'scrap_1_rcm', 'scrap_2_rcm', 'sdrm_mcs_2', 'sil_int',
    'sil_pred_mcs1', 'silj_ext', 'silj_int', 'silj_mcs1', 'silj_mcs2', 'smun_intro', 'smun_intro2', 'sol_1_ext',
    'sol_1_int_alt', 'sol_1_mcs_1_concat', 'sol_1_mcs_2', 'sol_1_mcs_3', 'sol_2_ext_concat', 'sol_2_int_alt1',
    'sol_3_int', 'sol_5_mcs_1', 'sol_5_mcs_2', 'sol_5_mcs_2_p5', 'sub_int', 'subj_ext', 'subj_mcs0', 'subj_mcs1',
    'sum23_cm1_int', 'sum23_cm1_int_p1', 'sum23_cm1_int_p1_t00', 'sum23_cm6_ext', 'sum23_cm6_ext_p1',
    'sum23_cm6_ext_p1_t00', 'sum24_btw_arralive_mcs5', 'sum24_btw_arralive_mcs6', 'sum24_btw_arrdead_mcs1',
    'sum24_btw_cell_ext', 'sum24_btw_dead_ext', 'sum24_bty3_ko_mcs2', 'sum24_bty4_heavy_mcs3',
    'sum24_bty6_escape_mcs4', 'sum24_office_int', 'sum25_bt2_carthief_mcs1', 'sum25_bt2_delivery_ext',
    'sum25_cayo_surv_ext', 'sum25_lsia_int', 'tale_intro', 'test_arm_2_mcs_6', 'test_jh_2a_intp4',
    'testbed_veh_blend', 'tmom_1_rcm', 'tmom_2_rcm', 'tonya_mcs_1', 'tonya_mcs_2', 'tonya_mcs_3', 'trevor_1_int',
    'trevor_2_int', 'trevor_drive_int', 'trv2_mcs_8', 'trv_1_mcs_1_p1', 'trv_1_mcs_3_concat', 'trv_1_mcs_4',
    'trv_2_mcs_4_concat', 'trv_2_mcs_6', 'trv_4_mcs_2', 'trv_5_ext', 'trv_5_int', 'trv_dri_ext', 'trv_dri_mcs_concat',
    'trvram_1', 'trvram_2_concat', 'trvram_3', 'trvram_4', 'trvram_5_con', 'tun_asd_ext', 'tun_meet_int',
    'tun_shop_ext', 'tun_shop_int', 'tunf_drp_avi', 'tunf_drp_bag', 'tunf_drp_hand', 'tunf_iaa_mcs1', 'tunf_uni_swat',
    'tunf_uni_vlt', 'under_int_1', 'under_int_1_p2', 'under_int_2', 'under_int_2_p2', 'under_int_3', 'under_int_4',
    'under_int_4_p2', 'under_int_4_p3', 'under_int_5', 'under_int_5_p2', 'under_int_6', 'under_int_6_p2',
    'under_int_6_p3', 'under_int_7', 'xm24_factory_int', 'xm24_mfh1_ext', 'xm24_mfh6_fin_ext',
    'xm24_mfh6_gun_drp_mcs2', 'xm24_mfh6_plne_dmg_mcs1', 'xm24_mfh_int', 'xm24_rob_crash_ext', 'xm24_rob_crash_mcs1',
    'xm25_avi5_ext', 'xm25_avi5_heli_mcs1', 'xm25_avi6_exta', 'xm25_avi6_extb', 'xm25_avi6_extc',
    'xm25_avi6_rescue_mcs1a', 'xm25_avi6_rescue_mcs1b', 'xm25_avi6_rescue_mcs1c', 'xm25_avi6_shutters_mcs2a',
    'xm25_avi6_shutters_mcs2b', 'xm25_avi6_shutters_mcs2c', 'xm25_avi_int', 'xm25_mansion_inta', 'xm25_mansion_intb',
    'xm25_mansion_intc', 'xm3_drg1_ace_int', 'xm3_drg1_bmx_int', 'xm3_drg1_trn_mcs1', 'xm3_drg2_cook_int',
    'xm3_drg2_cook_mcs1', 'xm3_drg2_pln_ext', 'xm3_drg2_pln_mcs1', 'xm3_drg2_pln_mcs2', 'xm3_drg2_pln_mcs3',
    'xm3_drg2_rhb_mcs1', 'xm4_cbr6_agg_int', 'xm4_cbr6_slth_int', 'xm4_cbr_fin_ext', 'xm4_cbr_fin_ext2',
    'xm4_cbr_vin_int', 'xm4_cbr_vin_int2', 'xm4_rob_cas_mcs1', 'xm4_rob_cas_mcs2', 'xm4_rob_ship_mcs1',
    'xm4_rob_sub_mcs1', 'xm4_rr_fin_mcs1', 'xm4_rr_fin_mcs2', 'xm4_yard_ext', 'xm4_yard_int',
    -- 2026-11-04: the Summer 2026 pack (mp2026_01), found in the game files
    'sum26_heist_int', 'sum26_kortz_cel', 'sum26_kortz_esc_mcs3', 'sum26_kortz_exta', 'sum26_kortz_extb',
    'sum26_kortz_las_mcs2', 'sum26_kortz_rpl_mcs1a', 'sum26_kortz_swr_mcs1c', 'sum26_kortz_van_mcs1b',
}

-- --- description builder -----------------------------------------------------------------------

local NUMWORD = { 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten' }

-- "armenian_3_mcs_5_concat" -> "Mid-mission scene 5 (full version)"
local function partOf(name)
    local n = name:lower()
    local base
    local mcs = n:match('_mcs_?(%d+)')
    if n:find('_mcs') then base = mcs and ('Mid-mission scene ' .. mcs) or 'Mid-mission scene'
    elseif n:find('_rcm') then base = 'Strangers and Freaks scene'
    elseif n:find('_cel') or n:find('celeb') then base = 'Celebration'
    elseif n:find('_fin_int') or n:find('_fin_ext') then base = n:find('_ext') and 'Finale, closing scene' or 'Finale, opening scene'
    elseif n:find('_int') or n:find('intro') then base = 'Opening scene'
    elseif n:find('_ext') then base = 'Closing scene'
    elseif n:find('_mid') then base = 'Halfway briefing'
    elseif n:find('_ig_') then base = 'In-mission moment'
    elseif n:find('hero_shot') then base = 'Hero shot'
    elseif n:find('_fin') then base = 'Finale scene'
    elseif n:find('_ent') then base = 'Way in'
    elseif n:find('_cs_%d') then base = 'Session ' .. (n:match('_(%d+)_cs') or '') .. ', scene ' .. (n:match('_cs_(%d+)') or '')
    else base = 'Scene' end
    local notes = {}
    local p = n:match('_pt?(%d+)') or n:match('intp(%d+)') or n:match('_p(%d+)[a-z]?$')
    if p then notes[#notes + 1] = 'part ' .. p end
    if n:find('concat') or n:find('_con$') then notes[#notes + 1] = 'full version' end
    if n:find('_alt') then notes[#notes + 1] = 'alternate take' end
    local v = n:match('_[a-z]+%d*([abc])$')
    if v and not n:find('_alt') then notes[#notes + 1] = 'version ' .. v:upper() end
    local int = n:match('_int(%d+)$') or n:match('_int_(%d+)$')
    if int and not p then notes[#notes + 1] = 'number ' .. (NUMWORD[tonumber(int)] or int) end
    return #notes > 0 and (base .. ' (' .. table.concat(notes, ', ') .. ')') or base
end

local function groupOf(name)
    local n = name:lower()
    for _, g in ipairs(GROUPS) do
        if n:find(g[1]) then return g[2] end
    end
    -- unknown: mp_ / mph_ prefixes are online, everything else stays unsorted
    if n:find('^mp') then return { src = 'online', set = 'GTA Online', title = 'GTA Online scene', blurb = 'An online scene not in the list yet.', guess = true } end
    return { src = 'other', set = 'Not in the list', title = 'Unknown scene', blurb = 'Not in the catalog yet: it may not load.', guess = true }
end

local function build(name)
    local g = groupOf(name)
    local part = partOf(name)
    local desc = OVERRIDES[name:lower()] or (('%s - %s. %s'):format(g.title, part, g.blurb))
    return {
        name = name, source = g.src, sourceLabel = SOURCES[g.src].label, set = g.set, mission = g.title, part = part,
        desc = desc, lead = (g.src == 'online' or g.src == 'dlc') and 'MP_1' or nil, guess = g.guess == true or nil,
    }
end

local byName, sorted = {}, nil

local function setOrder(e)
    if e.source == 'dlc' then return DLC_ORDER[e.set] or 99 end
    if e.source == 'story' then return STORY_ORDER[e.set] or 99 end
    return 1
end

local function catalog()
    if sorted then return sorted end
    sorted = {}
    for _, n in ipairs(NAMES) do
        if not byName[n] then byName[n] = build(n) sorted[#sorted + 1] = byName[n] end
    end
    table.sort(sorted, function(a, b)
        local sa, sb = SOURCES[a.source].order, SOURCES[b.source].order
        if sa ~= sb then return sa < sb end
        local oa, ob = setOrder(a), setOrder(b)
        if oa ~= ob then return oa < ob end
        if a.set ~= b.set then return a.set < b.set end
        if a.mission ~= b.mission then return a.mission < b.mission end
        return a.name < b.name
    end)
    return sorted
end

local function info(name)
    name = tostring(name or ''):lower()
    if name == '' then return nil end
    catalog()
    return byName[name] or build(name)
end

GlitchAbst = GlitchAbst or {}
GlitchAbst.Cutscene = GlitchAbst.Cutscene or {}
GlitchAbst.Cutscene.GetCatalog = catalog
GlitchAbst.Cutscene.GetInfo = info
GlitchAbst.Cutscene.Sources = SOURCES

-- exports['glitch-abstraction']:GetCutsceneCatalog() -> every entry (copy-safe: plain data)
exports('GetCutsceneCatalog', function() return catalog() end)
-- exports['glitch-abstraction']:GetCutsceneInfo('mp_intro_concat') -> entry or nil
exports('GetCutsceneInfo', function(name) return info(name) end)
