<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class DatabaseAvailabilityChecker extends Command
{
    /**
     * Sleep time between connection attempts in seconds.
     */
    private const WAIT_SLEEP_TIME = 2;

    /**
     * Maximum wait time for the database to be available in seconds.
     */
    private const MAX_WAIT_TIME = 60;

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'db:status';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Waits for database availability.';

    /**
     * Execute the console command.
     */
    public function handle(): bool
    {
        $startTime = time();
        $maxWaitTime = self::MAX_WAIT_TIME;
        $waitSleepTime = self::WAIT_SLEEP_TIME;

        $this->info('Waiting for the database to become available...');

        while (true) {
            try {
                // Attempt to query the database
                DB::select('SHOW TABLES');
                $this->info('🎉 Connection to the database is successful!');

                return 0;
            } catch (QueryException $exception) {

                // If the connection fails, log the attempt and sleep
                $elapsedTime = time() - $startTime;
                $this->error('❌ Unable to connect to the database within the expected time. ');
                $this->error($exception->getMessage());
                if ($elapsedTime >= $maxWaitTime) {
                    $this->error('Please check your database configuration and ensure it is running.');

                    return 1;
                }

                $remainingTime = $maxWaitTime - $elapsedTime;
                $this->comment('⏳ Database not available yet. Retrying in '.$waitSleepTime.' seconds... (Approx. '.$remainingTime.' seconds remaining)');
                sleep($waitSleepTime);
            }
        }
    }
}
