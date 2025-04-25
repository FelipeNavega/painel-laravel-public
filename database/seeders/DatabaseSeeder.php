<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use App\Enums\PartnerTypeEnum;
use App\Enums\UserTypeEnum;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Exception;

class DatabaseSeeder extends Seeder
{

    public function run(): void
    {
        // Executa arquivo SQL de municípios e estados
        try {
            $municipios_sql_path = database_path('municipios_estados_BR.sql');
            if (file_exists($municipios_sql_path)) {
                DB::unprepared(file_get_contents($municipios_sql_path));
                $this->command->info('Arquivo municipios_estados_BR.sql executado com sucesso.');
            } else {
                $this->command->warn('Arquivo municipios_estados_BR.sql não encontrado.');
            }
        } catch (Exception $e) {
            $this->command->error('Erro ao executar municipios_estados_BR.sql: ' . $e->getMessage());
        }

        // Limpa e executa arquivo SQL para bancos
        try {
            $banks_sql_path = database_path('banks.sql');
            if (file_exists($banks_sql_path)) {
                // Trunca a tabela banks antes de inserir novos registros
                DB::table('banks')->truncate();
                $this->command->info('Tabela banks foi limpa com sucesso.');

                // Agora executa o arquivo SQL
                DB::unprepared(file_get_contents($banks_sql_path));
                $this->command->info('Arquivo banks.sql executado com sucesso.');
            } else {
                $this->command->warn('Arquivo banks.sql não encontrado.');
            }
        } catch (Exception $e) {
            $this->command->error('Erro ao executar banks.sql: ' . $e->getMessage());
        }

        // Limpa e executa arquivo SQL para formulários
        try {
            $forms_sql_path = database_path('forms.sql');
            if (file_exists($forms_sql_path)) {
                // Trunca a tabela forms antes de inserir novos registros
                DB::table('forms')->truncate();
                $this->command->info('Tabela forms foi limpa com sucesso.');

                // Agora executa o arquivo SQL
                DB::unprepared(file_get_contents($forms_sql_path));
                $this->command->info('Arquivo forms.sql executado com sucesso.');
            } else {
                $this->command->warn('Arquivo forms.sql não encontrado.');
            }
        } catch (Exception $e) {
            $this->command->error('Erro ao executar forms.sql: ' . $e->getMessage());
        }

        // Cria usuários apenas se eles não existirem
        try {
            // Verifica se o usuário admin já existe
            if (!User::where('email', 'admin@email.com.br')->exists()) {
                User::create([
                    'name' => 'Admin',
                    'type' => UserTypeEnum::ADMIN,
                    'email' => 'admin@email.com.br',
                    'password' => 'VddE!-Dn@tJIaxl3Pse8'
                ]);
                $this->command->info('Usuário admin criado com sucesso.');
            } else {
                $this->command->info('Usuário admin já existe, ignorando criação.');
            }

            // Verifica se o usuário parceiro já existe
            if (!User::where('email', 'partner@email.com.br')->exists()) {
                User::create([
                    'name' => 'Parceiro',
                    'partner_type' => PartnerTypeEnum::OUTROS,
                    'type' => UserTypeEnum::PARTNER,
                    'email' => 'partner@email.com.br',
                    'password' => 'VddE!-Dn@tJIaxl3Pse8'
                ]);
                $this->command->info('Usuário parceiro criado com sucesso.');
            } else {
                $this->command->info('Usuário parceiro já existe, ignorando criação.');
            }
        } catch (Exception $e) {
            $this->command->error('Erro ao criar usuários: ' . $e->getMessage());
        }
    }
}
