Acumular valores de colunas
http://mabcorreia.blogspot.com.br/2014/03/acumular-valores-de-uma-soma.html


--Calcular o TMRO ( Tempo médio de resposta da ouvidoria), pegando a soma dos dias de tratamento e dividindo pela quantidade de demanda tratada acumulado do ano de 2017.
--fonte de dados: JIRA

SELECT MES_CRIACAO,QTDE_ISSUES_ACUMULADA,QTDE_DIAS_TRATAMENTO_ACUMULADO, (QTDE_DIAS_TRATAMENTO_ACUMULADO/QTDE_ISSUES_ACUMULADA)TMRO FROM
(
SELECT MES_CRIACAO,
       SUM(QTD_ISSUES) QTD_ISSUES,
       SUM(SUM(QTD_ISSUES)) OVER(ORDER BY MES_CRIACAO ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS QTDE_ISSUES_ACUMULADA,
       SUM(QTD_DIAS_TRATAMENTO)QTD_DIAS_TRATAMENTO,
       SUM(SUM(QTD_DIAS_TRATAMENTO)) OVER(ORDER BY MES_CRIACAO ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS QTDE_DIAS_TRATAMENTO_ACUMULADO
  FROM (SELECT MES_CRIACAO,
               COUNT(ISSUENUM) QTD_ISSUES,
               SUM(QTD_DIAS) QTD_DIAS_TRATAMENTO
          FROM (SELECT J.ISSUENUM,
                       TO_CHAR(J.CREATED, 'DD/MM/YYYY HH24:MM:SS') AS CRIADO,
                       TO_NUMBER(TO_CHAR(J.CREATED, 'MM')) MES_CRIACAO,
                       TO_CHAR(J.RESOLUTIONDATE, 'DD/MM/YYYY HH24:MM:SS') AS RESOLVIDO,
                       TO_NUMBER(TO_CHAR(J.RESOLUTIONDATE, 'MM')) MES_RESOLUCAO,
                       (CASE
                         WHEN TRUNC(J.CREATED) = TRUNC(SYSDATE) THEN
                          0
                         ELSE
                          U063.QTD_DIAS_UTEIS(TRUNC(J.CREATED + 1),
                                              NVL(TRUNC(J.RESOLUTIONDATE + 1),
                                                  J.RESOLUTIONDATE))
                       END) QTD_DIAS
                  FROM JIRADBUSER.JIRAISSUE J, JIRADBUSER.ISSUETYPE IT
                 WHERE 1 = 1
                   AND J.PROJECT = 11090
                   AND J.ISSUETYPE = IT.ID(+)
                   AND IT.PNAME = 'Ouvidoria'
                   AND J.CREATED >= '01/01/2017'
                   AND J.RESOLUTIONDATE IS NOT NULL
                 ORDER BY 3, 5)
         GROUP BY MES_CRIACAO
         ORDER BY 1, 2)
 GROUP BY MES_CRIACAO
 )
