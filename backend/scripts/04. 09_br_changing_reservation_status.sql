-- (BR-09) Une nouvelle réservation doit avoir le status pending.
-- Une réservation existante ne peut pas revenir "en arrière" dans son cycle de vie.
-- Les transitions autorisées sont :
-- pending -> confirmed
-- pending -> cancelled
-- confirmed -> completed
-- confirmed -> cancelled
-- La transition confirmed -> pending est autorisée dans certains cas (voir règles temporelles).

-- Aucune transition depuis completed ou cancelled n'est autorisée.

CREATE OR REPLACE FUNCTION fn_check_changing_reservation_status()
    RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.status != 'pending' THEN
            RAISE EXCEPTION 'Une nouvelle réservation doit être en attente';
        END IF;
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF OLD.status = NEW.status THEN
            RETURN NEW;
        END IF;

        IF OLD.status = 'pending' THEN
            IF NEW.status NOT IN ('confirmed', 'cancelled') THEN
                RAISE EXCEPTION 'Une réservation en attente ne peut qu''être confirmée ou annulée!';
            END IF;

        ELSEIF OLD.status = 'confirmed' THEN
            IF NEW.status = 'pending' THEN
                IF OLD.datetime <= (SELECT simulated_time FROM system_time) THEN
                    RAISE EXCEPTION 'La réservation n''est pas dans le futur pour repasser en attente!';
                END IF;
            ELSEIF NEW.status NOT IN ('completed', 'cancelled') THEN
                RAISE EXCEPTION 'Une réservation confirmée ne peut qu''être terminée ou annulée!';
            END IF;
        END IF;

        IF OLD.status IN ('completed', 'cancelled') THEN
            RAISE EXCEPTION 'Une réservation terminée ou annulée ne peut plus être modifiée!';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_changing_reservation_status ON reservations;
CREATE TRIGGER trg_check_changing_reservation_status
    BEFORE INSERT OR UPDATE
    ON reservations
    FOR EACH ROW
EXECUTE FUNCTION fn_check_changing_reservation_status();

