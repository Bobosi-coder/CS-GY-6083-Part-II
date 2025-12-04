import React, { useState, useEffect } from 'react';
import axiosClient from '../api/axiosClient';

const ReportQuery = ({ endpoint, title, question }) => {
    const [data, setData] = useState(null);
    const [error, setError] = useState('');

    useEffect(() => {
        axiosClient.get(`/admin/reports/${endpoint}`)
            .then(setData)
            .catch(err => setError(err.error || 'Failed to fetch report'));
    }, [endpoint]);

    const renderTable = (result) => {
        if (!result || result.length === 0) {
            return <p>No results found.</p>;
        }
        const headers = Object.keys(result[0]);
        return (
            <table>
                <thead>
                    <tr>
                        {headers.map(h => <th key={h}>{h}</th>)}
                    </tr>
                </thead>
                <tbody>
                    {result.map((row, i) => (
                        <tr key={i}>
                            {headers.map(h => <td key={h}>{String(row[h])}</td>)}
                        </tr>
                    ))}
                </tbody>
            </table>
        );
    };

    return (
        <div className="report-card">
            <h3>{title}</h3>
            <p><strong>Business Question:</strong> {question}</p>
            {error && <p className="error-message">{error}</p>}
            {data ? (
                <div>
                    <h4>SQL Query:</h4>
                    <pre><code>{data.query}</code></pre>
                    <h4>Results:</h4>
                    {renderTable(data.result)}
                </div>
            ) : <p>Loading...</p>}
        </div>
    );
};

const AdminReports = () => {
    const reports = [
        { endpoint: 'q1', title: 'Q1: Series with Genres and Release Countries', question: 'List all series with their genres and release countries.' },
        { endpoint: 'q2', title: 'Q2: Viewers who rated "Drama" series', question: "Find all viewers who have written feedback for any 'Drama' series." },
        { endpoint: 'q3', title: 'Q3: Feedback Above Series Average', question: 'Find feedback entries whose rating is above the average rating for that specific series.' },
        { endpoint: 'q4', title: 'Q4: Series with English Subtitles or Dubbing', question: 'List all series that have either English subtitles or English dubbing.' },
        { endpoint: 'q5', title: 'Q5: High-Rated Series with Multiple Feedbacks', question: 'Find high-rated series (avg rating > 4) that have at least 2 feedbacks.' },
        { endpoint: 'q6', title: 'Q6: Top 3 Most Active Viewers', question: 'Who are the top 3 most active viewers (by number of feedbacks given)?' }
    ];

    return (
        <div>
            <h2>Business Analysis Reports</h2>
            {reports.map(r => <ReportQuery key={r.endpoint} {...r} />)}
            <style>{`
                .report-card { border: 1px solid #ccc; padding: 1rem; margin-bottom: 1rem; border-radius: 5px; }
                pre { background-color: #f4f4f4; padding: 1rem; border-radius: 5px; white-space: pre-wrap; word-wrap: break-word; }
                table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #f2f2f2; }
            `}</style>
        </div>
    );
};

export default AdminReports;
