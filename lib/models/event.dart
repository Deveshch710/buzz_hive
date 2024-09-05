class events {
  final int eventid;
  final String eventname;
  final String location;
  final DateTime time;
  final String imageurl;
  final String eventurl;

  events(
      {required this.eventid,
        required this.eventname,
        required this.location,
        required this.time,
        required this.imageurl,
        required this.eventurl,
      });

  //List of Plants data
  static List<events> eventlist = [
    events(
        eventid: 0,
        eventname: 'Event 1',
        location: 'Indoor',
        time: DateTime(2024,05,01),
        imageurl: 'assets/images/img1.png',
        eventurl: '',
    ),
    events(
      eventid: 1,
      eventname: 'Event 2',
      location: 'Indoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),
    events(
      eventid: 2,
      eventname: 'Event 3',
      location: 'Indoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),
    events(
      eventid: 3,
      eventname: 'Event 4',
      location: 'outdoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),
    events(
      eventid: 4,
      eventname: 'Event 4',
      location: 'outdoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),
    events(
      eventid: 5,
      eventname: 'Event 4',
      location: 'outdoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),
    events(
      eventid: 6,
      eventname: 'Event 4',
      location: 'outdoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),events(
      eventid: 7,
      eventname: 'Event 4',
      location: 'outdoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),
    events(
      eventid: 8,
      eventname: 'Event 4',
      location: 'outdoor',
      time: DateTime(2024,05,01),
      imageurl: 'assets/images/img1.png',
      eventurl: '',
    ),


  ];


}

class details{
  final String firstname;
  final String lastname;
  final String dateofbirth;
  final String gender;
  final String emailid;
  final int phoneno;
  final String collegename;
  final int roolno;
  final String branch;
  final int year;

  final String dp;
  final String img1url;
  final String img2url;
  final String img3url;
  final String img4url;
  final String img5url;
  final String img6url;

  final String insta;
  final String linkedin;


  details(
      {
        required this.firstname,
        required this.lastname,
        required this.dateofbirth,
        required this.gender,
        required this.emailid,
        required this.phoneno,
        required this.collegename,
        required this.roolno,
        required this.branch,
        required this.year,

        required this.dp,
        required this.img1url,
        required this.img2url,
        required this.img3url,
        required this.img4url,
        required this.img5url,
        required this.img6url,

        required this.insta,
        required this.linkedin,


      });
}