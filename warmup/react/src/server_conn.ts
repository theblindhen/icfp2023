export async function send(route: string, body: any): Promise<any> {
  //
  const response = await fetch(route, {
    method: "POST",
    // mode: "no-cors",
    headers: {
      "Content-Type": "application/json",
      Accept: "*/*",
    },
    body: JSON.stringify(body),
  });
  console.log(response);
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  console.log(response);
  console.log(response.body);
  return response.json();
}
