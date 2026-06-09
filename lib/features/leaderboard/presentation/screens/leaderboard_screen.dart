import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Leaderboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Top 3 Podium
            _buildTopThreePodium(),
            SizedBox(height: 30.h),
            // Rest of the list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF191B28),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    final rank = index + 4;
                    return _buildLeaderboardTile(rank);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreePodium() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumAvatar(
            name: "Ahmed",
            points: "4.8k",
            rank: 2,
            color: Colors.grey.shade400,
            avatarRadius: 35.r,
            heightOffset: 20.h,
          ),
          SizedBox(width: 15.w),
          // 1st Place
          _buildPodiumAvatar(
            name: "Mohamed",
            points: "5.2k",
            rank: 1,
            color: Colors.amber,
            avatarRadius: 45.r,
            heightOffset: 40.h,
            isFirst: true,
          ),
          SizedBox(width: 15.w),
          // 3rd Place
          _buildPodiumAvatar(
            name: "Omar",
            points: "4.2k",
            rank: 3,
            color: Colors.brown.shade300,
            avatarRadius: 35.r,
            heightOffset: 10.h,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumAvatar({
    required String name,
    required String points,
    required int rank,
    required Color color,
    required double avatarRadius,
    required double heightOffset,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst)
          Icon(Icons.military_tech, color: Colors.amber, size: 40.sp)
        else
          SizedBox(height: 40.sp),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3.w),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: const Color(0xFF1E1E2A),
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -5.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "#$rank",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h + heightOffset),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          "$points pts",
          style: TextStyle(
            color: const Color(0xFF00D293),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(int rank) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              "#$rank",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20.r,
            backgroundColor: const Color(0xFF0F111A),
            child: Icon(Icons.person, color: Colors.grey.shade600),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              "Driver $rank",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${5000 - (rank * 150)} pts",
                style: TextStyle(
                  color: const Color(0xFF00D293),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${150 - (rank * 5)} trips",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
