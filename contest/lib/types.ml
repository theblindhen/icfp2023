type attendee = { x : float; y : float; tastes : float list }

type problem = {
  room_width : float;
  room_height : float;
  stage_width : float;
  stage_height : float;
  stage_bottom_left : float * float;
  musicians : int list;
  attendees : attendee list;
}
