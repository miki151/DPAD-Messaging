package com.dpad.messaging.databases

import androidx.room.testing.MigrationTestHelper
import androidx.sqlite.db.framework.FrameworkSQLiteOpenHelperFactory
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Rule
import org.junit.Test

class MigrationTest {

    private val testDb = "migration-test"

    @get:Rule
    val helper = MigrationTestHelper(
        InstrumentationRegistry.getInstrumentation(),
        MessagesDatabase::class.java,
        listOf(),
        FrameworkSQLiteOpenHelperFactory()
    )

    @Test
    fun migrate6To7KeepsOldMessagesUnencrypted() {
        helper.createDatabase(testDb, 6).apply {
            execSQL("INSERT INTO messages VALUES (1, 2, 'old SMS', 1, 100, 100, 1, '+15555550101', '', '', 0, -1, -1, 0, NULL, '', '')")
            close()
        }
        helper.runMigrationsAndValidate(testDb, 7, true, MessagesDatabase.MIGRATION_6_7).use { db ->
            db.query("SELECT body,is_encrypted FROM messages WHERE id=1").use { cursor ->
                org.junit.Assert.assertTrue(cursor.moveToFirst())
                org.junit.Assert.assertEquals("old SMS", cursor.getString(0))
                org.junit.Assert.assertEquals(0, cursor.getInt(1))
            }
        }
    }

    @Test
    fun migrate5To6() {
        helper.createDatabase(testDb, 5).close()

        helper.runMigrationsAndValidate(
            testDb,
            6,
            true,
            MessagesDatabase.MIGRATION_5_6
        )
    }
}
