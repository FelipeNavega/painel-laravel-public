<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Simulação de Consórcio</title>
    <style>
        body {
            margin-bottom: 60px; /* espaço para o footer */
            color: #332a61;      
            font-family: Calibri, sans-serif;
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            font-family: inherit;
        }
        table, th, td { 
            border: 1px solid #ddd; 
        }
        th, td { 
            padding: 8px;
            text-align: center; 
        }
        .page-break { 
            page-break-before: always; 
        }
        footer {
            position: fixed;
            bottom: 0;
            left: 0;
            text-align: center;
            width: 100%;
            font-size: 12px;
            padding: 10px 0;
            background-color: white;
            font-family: Calibri, sans-serif;
        }
    </style>
</head>
<body>  
    <?php
        $logoPath = resource_path('views/pdf/logo-11.webp');
        $logoBase64 = file_exists($logoPath) ? base64_encode(file_get_contents($logoPath)) : '';
    ?>
    @if($logoBase64)
        <div style="text-align: center; margin-bottom: 30px;">
            <img src="data:image/png;base64,{{ $logoBase64 }}" alt="Logo" width="190" height="50">
        </div>
    @else
        <p style="text-align: center;">Logo não encontrado.</p>
    @endif

    <!-- Tabela com duas colunas para os dados do consórcio -->
    <div style="text-align: center; margin-bottom: 20px;">
        <table style="margin: 0 auto; border: none;">
            <tr>
                <td style="padding: 5px 15px;">
                    <strong>Name:</strong> {{ $nome }}
                </td>
                <td style="padding: 5px 15px;">
                    <strong>Valor do Consórcio:</strong> R$ {{ number_format((float)$consortiumValue, 2, ',', '.') }}
                </td>
            </tr>
            <tr>
                <td style="padding: 5px 15px;">
                    <strong>Quantos Meses quer pagar:</strong> {{ $monthsPay }}
                </td>
                <td style="padding: 5px 15px;">
                    <strong>Data de Nascimento:</strong> {{ date('d/m/Y', strtotime($date_of_birth)) }}
                </td>
            </tr>
            <tr>
                <td style="padding: 5px 15px;">
                    <strong>Estado:</strong> {{ $state_name }}
                </td>
                <td style="padding: 5px 15px;">
                    <strong>Cidade:</strong> {{ $city_name }}
                </td>
            </tr>
            <tr>
                <td colspan="2" style="padding: 5px 15px;">
                    <strong>Informe a sua renda mensal:</strong> R$ {{ number_format((float)$monthlyIncome, 2, ',', '.') }}
                </td>
            </tr>
        </table>
    </div>

    <h1 style="text-align: center; font-size: 24px;">Simulação</h1>

    <p style="font-size: 12px;">
        <strong>Importante:</strong>
        Isto é apenas uma simulação. A efetivação do resultado apresentado está condicionada à análise de sua proposta de financiamento.
        A taxa de juros apresentada na simulação é apenas para referência.
    </p>

    <!-- Tabela com resultados dos bancos -->
    <div>
        <table>
            <thead>
                <tr>
                    <th>Banco</th>
                    <th>Taxa de Administração</th>
                    <th>Taxa de Reserva</th>
                    <th>Valor Total com Taxas</th>
                    <th>Valor das Parcelas</th>
                </tr>
            </thead>
            <tbody>
                @foreach($calculoResults as $key => $item)
                    @php
                        $bank = $banks[$key];
                        $extras = $bankExtras[$key];
                    @endphp
                    <tr>
                        <td>
                            <img src="{{ $bank['logo'] }}" alt="{{ $bank['name'] }}" height="50" width="50"><br>
                            {{ $bank['name'] }}
                        </td>
                        <td>{{ sprintf('%s%%', floatval($extras['tax_admin']) * 100) }}</td>
                        <td>{{ sprintf('%s%%', floatval($extras['reserva']) * 100) }}</td>
                        <td>{{ $item['finalValue'] }}</td>
                        <td>{{ $item['monthlyValue'] }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div style="margin-top: 10px;">
        <p><strong>Data:</strong> <?php echo date('d/m/Y'); ?> - <strong>Hora:</strong> <?php echo date('H:i'); ?></p>
    </div>

    <footer>
        <strong>Importante:</strong>
        Isto é apenas uma simulação. A efetivação do resultado apresentado está condicionada à análise de sua proposta de financiamento.
        A taxa de juros apresentada na simulação é apenas para referência.
    </footer>
</body>
</html>