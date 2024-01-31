ALTER TABLE dms_sample_dbo.player
ADD CONSTRAINT sport_team_fk 
FOREIGN KEY (sport_team_id) 
REFERENCES dms_sample_dbo.sport_team(id)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.seat
ADD CONSTRAINT seat_type_fk 
FOREIGN KEY (seat_type) 
REFERENCES dms_sample_dbo.seat_type(name)
ON DELETE CASCADE;

/*
 Skipping because of long wait time for the query to complete

 ALTER TABLE dms_sample_dbo.seat
 ALTER COLUMN sport_location_id TYPE numeric;

 ALTER TABLE dms_sample_dbo.seat
 ADD CONSTRAINT s_sport_location_fk 
 FOREIGN KEY (sport_location_id)
 REFERENCES dms_sample_dbo.sport_location(id)
 ON DELETE CASCADE;
*/

ALTER TABLE dms_sample_dbo.sport_division
ADD CONSTRAINT sd_sport_type_fk 
FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample_dbo.sport_type (name)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.sport_division
ADD CONSTRAINT sd_sport_league_fk
FOREIGN KEY (sport_league_short_name) 
REFERENCES dms_sample_dbo.sport_league (short_name)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.sport_league
ADD CONSTRAINT sl_sport_type_fk 
FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample_dbo.sport_type (name);

ALTER TABLE dms_sample_dbo.sport_team
ADD CONSTRAINT st_sport_type_fk 
FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample_dbo.sport_type (name)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.sport_team
ADD CONSTRAINT home_field_fk 
FOREIGN KEY (home_field_id) 
REFERENCES dms_sample_dbo.sport_location (id)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.sporting_event
ADD CONSTRAINT se_sport_type_fk 
FOREIGN KEY (sport_type_name) 
REFERENCES dms_sample_dbo.sport_type (name);

ALTER TABLE dms_sample_dbo.sporting_event
ADD CONSTRAINT se_away_team_id_fk 
FOREIGN KEY (away_team_id) 
REFERENCES dms_sample_dbo.sport_team (id)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.sporting_event
ADD CONSTRAINT se_home_team_id_fk 
FOREIGN KEY (home_team_id) 
REFERENCES dms_sample_dbo.sport_team (id);

ALTER TABLE dms_sample_dbo.sporting_event_ticket
ADD  CONSTRAINT set_person_id 
FOREIGN KEY(ticketholder_id)
REFERENCES dms_sample_dbo.person (id)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.sporting_event_ticket
ADD CONSTRAINT set_sporting_event_fk 
FOREIGN KEY (sporting_event_id) 
REFERENCES dms_sample_dbo.sporting_event (id)
ON DELETE CASCADE;

/*
Skipping because of long wait time for the query to complete

ALTER TABLE dms_sample_dbo.sporting_event_ticket
ALTER COLUMN sport_location_id TYPE numeric;

ALTER TABLE dms_sample_dbo.sporting_event_ticket
ADD CONSTRAINT set_seat_fk 
FOREIGN KEY (sport_location_id, seat_level, seat_section, seat_row, seat) 
REFERENCES dms_sample_dbo.seat (sport_location_id, seat_level, seat_section, seat_row, seat);
*/

ALTER TABLE dms_sample_dbo.ticket_purchase_hist
ADD CONSTRAINT tph_sport_event_tic_id 
FOREIGN KEY (sporting_event_ticket_id) 
REFERENCES dms_sample_dbo.sporting_event_ticket (id)
ON DELETE CASCADE;

ALTER TABLE dms_sample_dbo.ticket_purchase_hist
ADD CONSTRAINT tph_ticketholder_id 
FOREIGN KEY (purchased_by_id) 
REFERENCES dms_sample_dbo.person (id);

ALTER TABLE dms_sample_dbo.ticket_purchase_hist
ADD CONSTRAINT tph_transfer_from_id 
FOREIGN KEY (transferred_from_id) 
REFERENCES dms_sample_dbo.person (id);

-----these are here for reference they take a while to rebuild so not required for the lab only if you want to 
------
---CREATE INDEX set_ev_id_tkholder_id_idx ON dms_sample.sporting_event_ticket (sporting_event_id float8_ops,ticketholder_id float8_ops);
---CREATE INDEX set_seat_idx ON dms_sample.sporting_event_ticket USING btree (sport_location_id, seat_level, seat_section, seat_row, seat);
---CREATE INDEX set_sporting_event_idx ON dms_sample.sporting_event_ticket USING btree (sporting_event_id);
---CREATE INDEX set_ticketholder_idx ON dms_sample.sporting_event_ticket USING btree (ticketholder_id);