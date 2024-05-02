module stop_rd_pg_bndry_tracking
(
start_track,
start_track_sync,
stop_read
);

input  start_track;
input  start_track_sync;
output stop_read;

assign stop_read = start_track_sync==0 && start_track==0;

endmodule 

