type position = { x : float; y : float }
type attendee = { pos : position; tastes : float list }

type problem = {
  room_width : float;
  room_height : float;
  stage_width : float;
  stage_height : float;
  stage_bottom_left : position;
  musicians : int list;
  attendees : attendee list;
}

type solution = position list
