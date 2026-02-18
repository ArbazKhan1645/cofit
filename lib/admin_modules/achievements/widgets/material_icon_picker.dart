import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class MaterialIconPicker extends StatefulWidget {
  final int currentIconCode;
  final ValueChanged<int> onIconSelected;

  const MaterialIconPicker({
    super.key,
    required this.currentIconCode,
    required this.onIconSelected,
  });

  @override
  State<MaterialIconPicker> createState() => _MaterialIconPickerState();
}

class _MaterialIconPickerState extends State<MaterialIconPicker> {
  final searchController = TextEditingController();
  String searchQuery = '';

  List<_IconEntry> get filteredIcons {
    if (searchQuery.isEmpty) return _allIcons;
    final q = searchQuery.toLowerCase();
    return _allIcons.where((i) => i.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
      child: Container(
        width: double.infinity,
        height: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Icon',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search icons...',
                prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                filled: true,
                fillColor: AppColors.bgCream,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (v) => setState(() => searchQuery = v),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filteredIcons.isEmpty
                  ? Center(
                      child: Text(
                        'No icons found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: filteredIcons.length,
                      itemBuilder: (context, index) {
                        final entry = filteredIcons[index];
                        final isSelected =
                            entry.codePoint == widget.currentIconCode;
                        final iconData = IconData(
                          entry.codePoint,
                          fontFamily: 'MaterialIcons',
                        );
                        return GestureDetector(
                          onTap: () {
                            widget.onIconSelected(entry.codePoint);
                            Get.back();
                          },
                          child: Tooltip(
                            message: entry.name,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.bgCream,
                                borderRadius: AppRadius.small,
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primaryDark,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                size: 26,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CURATED ICON LIST (~120 fitness/achievement icons)
  // ============================================

  static final List<_IconEntry> _allIcons = [
    // Fitness & Exercise
    _IconEntry('Fitness Center', Icons.fitness_center.codePoint),
    _IconEntry('Directions Run', Icons.directions_run.codePoint),
    _IconEntry('Directions Walk', Icons.directions_walk.codePoint),
    _IconEntry('Directions Bike', Icons.directions_bike.codePoint),
    _IconEntry('Sports Martial Arts', Icons.sports_martial_arts.codePoint),
    _IconEntry('Self Improvement', Icons.self_improvement.codePoint),
    _IconEntry('Sports Gymnastics', Icons.sports_gymnastics.codePoint),
    _IconEntry('Hiking', Icons.hiking.codePoint),
    _IconEntry('Surfing', Icons.surfing.codePoint),
    _IconEntry('Pool', Icons.pool.codePoint),
    _IconEntry('Sports Tennis', Icons.sports_tennis.codePoint),
    _IconEntry('Sports Handball', Icons.sports_handball.codePoint),
    _IconEntry('Sports Soccer', Icons.sports_soccer.codePoint),
    _IconEntry('Sports Basketball', Icons.sports_basketball.codePoint),
    _IconEntry('Skateboarding', Icons.skateboarding.codePoint),
    _IconEntry('Snowboarding', Icons.snowboarding.codePoint),
    _IconEntry('Sports Kabaddi', Icons.sports_kabaddi.codePoint),
    _IconEntry('Rowing', Icons.rowing.codePoint),

    // Body & Health
    _IconEntry('Favorite', Icons.favorite.codePoint),
    _IconEntry('Heart', Icons.favorite_border.codePoint),
    _IconEntry('Monitor Heart', Icons.monitor_heart.codePoint),
    _IconEntry('Health Safety', Icons.health_and_safety.codePoint),
    _IconEntry('Spa', Icons.spa.codePoint),
    _IconEntry('Local Drink', Icons.local_drink.codePoint),
    _IconEntry('Restaurant', Icons.restaurant.codePoint),
    _IconEntry('Psychology', Icons.psychology.codePoint),
    _IconEntry('Accessibility', Icons.accessibility_new.codePoint),
    _IconEntry('Body', Icons.boy.codePoint),

    // Achievement & Trophy
    _IconEntry('Trophy', Icons.emoji_events.codePoint),
    _IconEntry('Medal', Icons.military_tech.codePoint),
    _IconEntry('Workspace Premium', Icons.workspace_premium.codePoint),
    _IconEntry('Star', Icons.star.codePoint),
    _IconEntry('Star Border', Icons.star_border.codePoint),
    _IconEntry('Stars', Icons.stars.codePoint),
    _IconEntry('Diamond', Icons.diamond.codePoint),
    _IconEntry('Verified', Icons.verified.codePoint),
    _IconEntry('Check Circle', Icons.check_circle.codePoint),
    _IconEntry('Thumb Up', Icons.thumb_up.codePoint),
    _IconEntry('Celebration', Icons.celebration.codePoint),
    _IconEntry('Auto Awesome', Icons.auto_awesome.codePoint),
    _IconEntry('Grade', Icons.grade.codePoint),
    _IconEntry('Loyalty', Icons.loyalty.codePoint),
    _IconEntry('Toll', Icons.toll.codePoint),

    // Fire & Energy
    _IconEntry('Fire', Icons.local_fire_department.codePoint),
    _IconEntry('Whatshot', Icons.whatshot.codePoint),
    _IconEntry('Bolt', Icons.bolt.codePoint),
    _IconEntry('Flash On', Icons.flash_on.codePoint),
    _IconEntry('Rocket Launch', Icons.rocket_launch.codePoint),
    _IconEntry('Speed', Icons.speed.codePoint),
    _IconEntry('Electric Bolt', Icons.electric_bolt.codePoint),
    _IconEntry('Power', Icons.power.codePoint),

    // Time & Calendar
    _IconEntry('Timer', Icons.timer.codePoint),
    _IconEntry('Alarm', Icons.alarm.codePoint),
    _IconEntry('Access Time', Icons.access_time.codePoint),
    _IconEntry('Calendar Today', Icons.calendar_today.codePoint),
    _IconEntry('Date Range', Icons.date_range.codePoint),
    _IconEntry('Schedule', Icons.schedule.codePoint),
    _IconEntry('Event Available', Icons.event_available.codePoint),
    _IconEntry('History', Icons.history.codePoint),
    _IconEntry('Update', Icons.update.codePoint),
    _IconEntry('Hourglass', Icons.hourglass_bottom.codePoint),

    // Nature & Outdoors
    _IconEntry('Terrain', Icons.terrain.codePoint),
    _IconEntry('Landscape', Icons.landscape.codePoint),
    _IconEntry('Park', Icons.park.codePoint),
    _IconEntry('Forest', Icons.forest.codePoint),
    _IconEntry('Water Drop', Icons.water_drop.codePoint),
    _IconEntry('Air', Icons.air.codePoint),
    _IconEntry('Sunny', Icons.wb_sunny.codePoint),
    _IconEntry('Nightlight', Icons.nightlight_round.codePoint),
    _IconEntry('Cloud', Icons.cloud.codePoint),
    _IconEntry('Eco', Icons.eco.codePoint),

    // Progress & Charts
    _IconEntry('Trending Up', Icons.trending_up.codePoint),
    _IconEntry('Show Chart', Icons.show_chart.codePoint),
    _IconEntry('Bar Chart', Icons.bar_chart.codePoint),
    _IconEntry('Insights', Icons.insights.codePoint),
    _IconEntry('Leaderboard', Icons.leaderboard.codePoint),
    _IconEntry('Analytics', Icons.analytics.codePoint),
    _IconEntry('Timeline', Icons.timeline.codePoint),
    _IconEntry('Stacked Line', Icons.stacked_line_chart.codePoint),
    _IconEntry('Data Usage', Icons.data_usage.codePoint),
    _IconEntry('Pie Chart', Icons.pie_chart.codePoint),

    // People & Community
    _IconEntry('Group', Icons.group.codePoint),
    _IconEntry('Groups', Icons.groups.codePoint),
    _IconEntry('Person', Icons.person.codePoint),
    _IconEntry('Diversity', Icons.diversity_1.codePoint),
    _IconEntry('Volunteer', Icons.volunteer_activism.codePoint),
    _IconEntry('Handshake', Icons.handshake.codePoint),
    _IconEntry('People', Icons.people.codePoint),
    _IconEntry('Connect', Icons.connect_without_contact.codePoint),
    _IconEntry('Public', Icons.public.codePoint),
    _IconEntry('Share', Icons.share.codePoint),

    // Symbols & Misc
    _IconEntry('Flag', Icons.flag.codePoint),
    _IconEntry('Explore', Icons.explore.codePoint),
    _IconEntry('Map', Icons.map.codePoint),
    _IconEntry('Place', Icons.place.codePoint),
    _IconEntry('Navigation', Icons.navigation.codePoint),
    _IconEntry('Target', Icons.gps_fixed.codePoint),
    _IconEntry('Lightbulb', Icons.lightbulb.codePoint),
    _IconEntry('Extension', Icons.extension.codePoint),
    _IconEntry('Puzzle', Icons.interests.codePoint),
    _IconEntry('Shield', Icons.shield.codePoint),
    _IconEntry('Lock Open', Icons.lock_open.codePoint),
    _IconEntry('Key', Icons.vpn_key.codePoint),
    _IconEntry('Cake', Icons.cake.codePoint),
    _IconEntry('Music Note', Icons.music_note.codePoint),
    _IconEntry('Camera', Icons.camera_alt.codePoint),
    _IconEntry('Brush', Icons.brush.codePoint),
    _IconEntry('Palette', Icons.palette.codePoint),
    _IconEntry('School', Icons.school.codePoint),
    _IconEntry('Science', Icons.science.codePoint),
    _IconEntry('Construction', Icons.construction.codePoint),
    _IconEntry('Build', Icons.build.codePoint),
    _IconEntry('Savings', Icons.savings.codePoint),
    _IconEntry('Sunny Snowing', Icons.sunny_snowing.codePoint),
    _IconEntry('Sunny', Icons.sunny.codePoint),
  ];
}

class _IconEntry {
  final String name;
  final int codePoint;
  const _IconEntry(this.name, this.codePoint);
}
