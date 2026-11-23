package com.zedox.meshtalk.database;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.Query;
import com.zedox.meshtalk.models.Contact;
import java.util.List;

@Dao
public interface ContactDao {
    @Query("SELECT * FROM contacts")
    List<Contact> getAll();

    @Insert
    void insert(Contact contact);

    @Delete
    void delete(Contact contact);

    @Query("SELECT * FROM contacts WHERE deviceId = :deviceId LIMIT 1")
    Contact findByDeviceId(String deviceId);
}
