# IT Support Automation

> **Status:** concluído

Dois scripts de automação para tarefas rotineiras de suporte técnico, unindo administração Windows (PowerShell) e programação (Python).

## Objetivo

Demonstrar capacidade de ir além do atendimento manual de chamados, automatizando coletas de diagnóstico e verificações de rede — tarefas que, feitas à mão, consomem tempo da equipe de suporte.

## Scripts

### `system_report.ps1` (PowerShell)
Coleta hostname, IP, versão do Windows, uso de memória RAM e espaço em disco de uma máquina, e salva o resultado em um relatório `.txt`.

```powershell
.\system_report.ps1
```

### `ping_sweep.py` (Python)
Varre uma faixa de IPs da rede local em paralelo e identifica quais estão ativos, respondendo a ping.

```bash
python ping_sweep.py 192.168.1
```

## Tecnologias

- PowerShell (CIM/WMI, manipulação de arquivos)
- Python (subprocess, concurrent.futures)

## Possíveis evoluções

- Exportar o relatório do PowerShell em `.csv`/`.json`
- Resolver hostname de cada IP ativo no ping sweep
- Agendar `system_report.ps1` via Agendador de Tarefas do Windows
